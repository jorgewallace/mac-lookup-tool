# MAC Vendor Lookup CLI

A lightweight, high-performance command-line utility for identifying hardware vendors through MAC addresses. Designed for network administrators and security professionals.

## Key Features
- **Automated Installation:** Single script setup with Python virtual environment (VENV) isolation.
- - **Advanced Normalization:** Intelligent regex engine that handles multiple MAC formats:
  - Standard (`00:11:22...`)
  - Cisco Style (`0000.0C11...`)
  - Hyphenated (`FC-4C-EA...`)
  - Raw Hex (`44F79F...`)
  - Huawei like (`0000-1111...`)
- **Rich Output:** Clean, colorized tables for easy data reading.
- **Bulk Processing:** Supports manual input or file-based lookup (TXT).
- **IEEE Database Sync:** Simple command to update the OUI database to the latest version.

## Built With
This tool leverages the powerful [mac-vendor-lookup](https://github.com/bauerj/mac_vendor_lookup) library for accurate and fast OUI resolution.

## Installation

Run the installer with root privileges to set up the environment and binary:

```bash
# Clone the repository and run the installer
cd mac-lookup-tool
chmod +x install.sh
sudo ./install.sh
```

Usage
1. Simple & Multi-MAC Lookup
```
# Basic lookup for a single MAC address
maclookup 00:11:22:33:44:55

# Bulk lookup with mixed formats:
# Supports Standard, Cisco-style, Hyphenated, and Raw Hex formats simultaneously
maclookup 00:11:22:33:44:55 FC-4C-EA-D7-DE-D8 00D0-F6C8-2403 44F79F737523 0000.0C11.2233
```
<img width="1214" height="416" alt="image" src="https://github.com/user-attachments/assets/e66e0a01-6147-4193-835d-e7b2b52db34a" />

2. File-Based Batch Processing
```
# Process a plain text file (extracts MACs using regex)
maclookup --file macs.txt
```

3. Database Maintenance
```
maclookup --update
```



