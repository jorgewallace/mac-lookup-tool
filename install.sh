#!/bin/bash

# --- Configuration ---
APP_NAME="maclookup"
INSTALL_DIR="/opt/mac-lookup"
BINARY_PATH="/usr/local/bin/$APP_NAME"
VENV_PATH="$INSTALL_DIR/venv"

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

echo -e "${COLOR_BLUE}Starting $APP_NAME installation...${COLOR_RESET}"

if [ "$EUID" -ne 0 ]; then 
    echo "Error: This script must be run as root (sudo)."
    exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
REAL_GROUP=$(id -gn "$REAL_USER")


echo "Creating application directories at $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR/data" "/var/log/$APP_NAME"
chown -R "$REAL_USER:$REAL_GROUP" "$INSTALL_DIR"


echo "Configuring Python virtual environment..."
sudo -u "$REAL_USER" python3 -m venv "$VENV_PATH"
sudo -u "$REAL_USER" "$VENV_PATH/bin/pip" install --upgrade pip --quiet
sudo -u "$REAL_USER" "$VENV_PATH/bin/pip" install mac-vendor-lookup pandas rich --quiet


echo "Generating binary at $BINARY_PATH..."

cat << EOF > "$BINARY_PATH"
#!/opt/mac-lookup/venv/bin/python3
import sys, os, re, argparse
import pandas as pd
from mac_vendor_lookup import MacLookup, BaseMacLookup
from rich.console import Console
from rich.table import Table

# Set cache path to installation directory
BaseMacLookup.cache_path = '$INSTALL_DIR/mac-vendors.cache'
console = Console()

def get_vendor(mac):
    try:
        clean = "".join(re.findall(r'[0-9A-Fa-f]', mac))
        if len(clean) != 12: return "[red]Invalid Format[/red]"
        formatted = ":".join(clean[i:i+2] for i in range(0, 12, 2)).upper()
        return MacLookup().lookup(formatted)
    except Exception:
        return "[yellow]Vendor Not Found[/yellow]"

def main():
    parser = argparse.ArgumentParser(description="MAC Address Vendor Lookup Utility")
    parser.add_argument("macs", nargs="*", help="MAC addresses separated by spaces")
    parser.add_argument("-f", "--file", help="Input file (TXT)")
    parser.add_argument("-u", "--update", action="store_true", help="Update OUI database")
    
    args = parser.parse_args()
    
    if args.update:
        console.print("[blue]Updating OUI database...[/blue]")
        MacLookup().update_vendors()
        return

    inputs = args.macs
    if args.file and os.path.exists(args.file):
        with open(args.file) as f:
            content = f.read()
            regex = r'([0-9a-fA-F]{2,4}[:.-]?){2,6}[0-9a-fA-F]{2,4}|[0-9a-fA-F]{8,12}'
            matches = re.finditer(regex, content)
            inputs += [m.group(0) for m in matches]

    if not inputs:
        parser.print_help()
        return
    seen = set()
    unique_inputs = [x for x in inputs if not (x in seen or seen.add(x))]

    data = []
    for m in unique_inputs:
        clean_len = len("".join(re.findall(r'[0-9A-Fa-f]', m)))
        if clean_len >= 8:
            data.append({"MAC": m, "VENDOR": get_vendor(m)})

    table = Table(title="MAC Lookup Results", border_style="blue", show_lines=True)
    table.add_column("MAC Address", style="cyan")
    table.add_column("Vendor", style="green")
    
    for item in data:
        table.add_row(item["MAC"], item["VENDOR"])
    
    console.print(table)

if __name__ == "__main__":
    main()
EOF

chmod +x "$BINARY_PATH"

echo -e "\n${COLOR_GREEN}Installation completed successfully.${COLOR_RESET}"
echo -e "Usage: ${COLOR_BLUE}$APP_NAME 00:11:22:33:44:55 or ${COLOR_RESET}"
echo -e "Usage: ${COLOR_BLUE}$APP_NAME 00:11:22:33:44:55 00:11:22:33:44:5 or ${COLOR_RESET}"
echo -e "Usage: ${COLOR_BLUE}$APP_NAME --file mac.txt or ${COLOR_RESET}"
echo -e "Usage: ${COLOR_BLUE}$APP_NAME --update${COLOR_RESET}"
