# cavlite

## Installation

You can install `cavlite` with a single command:

```bash
curl -fsSL https://github.com/HexmosTech/cavlite/releases/latest/download/install.sh | sudo bash
```

To install a specific version (e.g., `v0.0.2`), run:

```bash
curl -fsSL https://github.com/HexmosTech/cavlite/releases/latest/download/install.sh | sudo bash -s -- --v0.0.2
```

This script will:

* Check for dependencies (`python3`, `curl`, `clamav`, `lynis`).
* Install `cavlite` to `/usr/local/bin/cavlite`.
* Install helper scripts and configurations.
* Configure ClamAV with optimized settings.
