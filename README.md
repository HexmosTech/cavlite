# `cavlite`: **Lightweight, Memory-Efficient Security Audit for Low-RAM Servers.**


`cavlite` is a wrapper around **ClamAV** and **Lynis** designed specifically for servers with limited resources (e.g., 4GB RAM or less). It orchestrates the scanning process to ensure maximum memory efficiency without sacrificing security.

## Problem: Why `clamscan` Is a Problem on Low-RAM Servers

The standard `clamscan` utility is resource-intensive. Every time it runs, it loads the entire virus database (600MB–900MB+) into RAM, performs the scan, and then unloads it. On a server with limited memory, this sudden spike can cause:

* System slowdowns.
* OOM (Out of Memory) kills.
* Service interruptions.

## Solution: `clamd` on Demand

`cavlite` solves this by using `clamd` (the ClamAV daemon) intelligently. Instead of letting `clamscan` load the DB repeatedly or keeping `clamd` running 24/7 (wasting RAM when not scanning), `cavlite`:

1. **Starts** the daemon only when a scan is requested.
2. **Uses** the daemon to scan efficiently.
3. **Stops** the daemon immediately after the scan to free up resources.

This approach gives you the speed of the daemon without the permanent memory footprint.

## Core Logic

Here is how `cavlite` performs a security audit:

1. **Checks**: Verifies root privileges and ensures no other scan is running.
2. **Daemon Startup**: Starts `clamav-daemon` and waits for it to load the virus definitions.
3. **Security Scan**:
    * Runs **ClamAV** using the daemon to scan files.
    * Moves infected files to the quarantine directory (`/var/quarantine` by default).
    * Runs **Lynis** for a system-wide security audit.
4. **Cleanup**: Stops `clamav-daemon` to release RAM back to the system.
5. **Reporting**: Generates a summary log and sends a notification (if configured).

## Installation

You can install `cavlite` with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/HexmosTech/cavlite/main/install.sh | sudo bash
```

To install a specific version (e.g., `v0.0.2`), run:

```bash
curl -fsSL https://raw.githubusercontent.com/HexmosTech/cavlite/main/install.sh | sudo bash -s -- --v0.0.2
```

This script will:

* Check for dependencies (`python3`, `curl`, `clamav`, `lynis`).
* Install `cavlite` to `/usr/local/bin/cavlite`.
* Install helper scripts and configurations.
* Configure ClamAV with optimized settings.

## Usage

Run `cavlite` as root:

```bash
sudo cavlite [COMMAND]
```

| Command | Description |
| :--- | :--- |
| `--start` | Start the security scan (ClamAV + Lynis). |
| `--stop` | Stop any running security scan and cleanup processes. |
| `--check-discord` | Send a test notification to the configured Discord webhook. |
| `--help` | Display the help message. |

## Configuration

Configuration is loaded from `/etc/cavlite/cavlite.conf`.

```bash
# /etc/cavlite/cavlite.conf

# Discord Webhook URL for notifications
WEBHOOK_URL="https://discord.com/api/webhooks/..."

# Root Directory to scan
SCAN_PATH="/" 

# Directory to move infected files
QUARANTINE_DIR="/var/quarantine"
```


