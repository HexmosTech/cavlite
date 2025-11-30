# `CAVLite`: **Lightweight, Memory-Efficient Security Audit for Low-RAM Servers.**

`CAVLite` is a wrapper around **[ClamAV](https://www.clamav.net/)** and **[Lynis](https://cisofy.com/lynis/)** designed specifically for servers with limited resources (e.g., 4GB RAM or less). It orchestrates the scanning process to ensure maximum memory efficiency without sacrificing security.

## Problem: Why `clamscan` Is a Problem on Low-RAM Servers

The standard [`clamscan`](https://docs.clamav.net/manual/Usage/Scanning.html#clamscan) utility is resource-intensive. Every time it runs, it loads the entire virus database (600MB–900MB+) into RAM, performs the scan, and then unloads it. On a server with limited memory, this sudden spike can cause:

* System slowdowns.
* OOM (Out of Memory) kills.
* Service interruptions.

## Solution: `clamd` on Demand

`CAVLite` solves this by using `clamd` (the ClamAV daemon) intelligently. Instead of letting `clamscan` load the DB repeatedly or keeping `clamd` running 24/7 (wasting RAM when not scanning), `CAVLite`:

1. **Starts** the daemon only when a scan is requested.
2. **Uses** the daemon (via [`clamdscan`](https://docs.clamav.net/manual/Usage/Scanning.html#clamdscan)) to scan efficiently.
3. **Stops** the daemon immediately after the scan to free up resources.

This approach gives you the speed of the daemon without the permanent memory footprint.

## Core Logic

`CAVLite` performs a security audit by :

1. **Checks**: Verifies root privileges and ensures no other scan is running.
2. **Daemon Startup**: Starts `clamav-daemon` and waits for it to load the virus definitions.
3. **Security Scan**:
    * Runs **[ClamAV](https://www.clamav.net/)** using the daemon to scan files.
    * Moves infected files to the quarantine directory (`/var/quarantine` by default).
    * Runs **[Lynis](https://cisofy.com/lynis/)** for a system-wide security audit.
4. **Cleanup**: Stops `clamav-daemon` to release RAM back to the system.
5. **Reporting**: Generates a summary log and sends a notification (if configured).

## Installation

You can install `CAVLite` with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/HexmosTech/CAVLite/main/install.sh | sudo bash
```

To install a specific version (e.g., `v0.0.2`), run:

```bash
curl -fsSL https://raw.githubusercontent.com/HexmosTech/CAVLite/main/install.sh | sudo bash -s -- --v0.0.2
```

This script will:

* Check for dependencies (`python3`, `curl`, `clamav`, `lynis`).
* Install `CAVLite` to `/usr/local/bin/CAVLite`.
* Install helper scripts and configurations.
* Configure ClamAV with optimized settings.

## Usage

Run `CAVLite` as root:

```bash
sudo CAVLite [COMMAND]
```

| Command | Description |
| :--- | :--- |
| `--start` | Start the security scan (ClamAV + Lynis). |
| `--stop` | Stop any running security scan and cleanup processes. |
| `--check-discord` | Send a test notification to the configured Discord webhook. |
| `--help` | Display the help message. |

## Configuration

Configuration is loaded from `/etc/CAVLite/CAVLite.conf`.

```bash
# /etc/CAVLite/CAVLite.conf

# Discord Webhook URL for notifications
WEBHOOK_URL="https://discord.com/api/webhooks/..."

# Root Directory to scan
SCAN_PATH="/" 

# Directory to move infected files
QUARANTINE_DIR="/var/quarantine"
```

## Credits


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
