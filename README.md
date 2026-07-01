# Antigravity Community Installer (Linux)

An interactive, community-driven installation script for the Antigravity product suite on Linux. 

> [!NOTE]
> **Disclaimer:** This is an unofficial community installer and is not directly affiliated with or officially supported by Google. Use at your own risk.

The official installation method for Antigravity Version 2 requires downloading an archive, manually extracting it, and then performing multiple manual steps to setup the IDE and Agent Manager correctly. This script automates all of those processes for you, creating a seamless, one-click installation experience.

## Features

- **Interactive UI**: A simple terminal-based menu to choose which components to install (IDE, Agent Manager, CLI).
- **Auto-Fetching**: Automatically contacts the official Antigravity cloud API to fetch the absolute latest stable releases for Linux x64.
- **Smart Cleanup**: Downloads to `/tmp/ag_installer_tmp` and deletes the archives after extraction to save disk space.
- **Process Management**: Automatically detects and terminates any stale "single-instance locks" before installing to ensure your apps open cleanly on the first click.
- **Desktop Shortcuts**: Automatically generates proper `.desktop` entries in your system menu so you can launch the tools via your application launcher.

## Components

You can choose to install any combination of the following:

1. **Antigravity Agent Manager**: The standalone control panel and hub for the Antigravity ecosystem.
2. **Antigravity IDE**: The standalone Code Engine application (Version 2.0+).
3. **CLI Engine (agy)**: The command-line interface tool.

## Prerequisites

Ensure your system has the following utilities installed:
- `bash`
- `curl`
- `tar`
- `sudo` (The script requires root privileges to place applications into `/opt/`)

## Installation & Usage

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-username/Antigravity-installer.git
   cd Antigravity-installer
   ```

2. Make the script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installer:
   ```bash
   ./install.sh
   ```

4. Follow the interactive prompts:
   - Use the **Arrow Keys** to navigate.
   - Use the **Spacebar** to toggle a component on/off.
   - Press **Enter** to confirm your selection and begin the installation.
   - (Press **Ctrl+C** to cancel at any time).

## Troubleshooting

- **"Command not found" for agy:** Ensure that `~/.local/bin` is in your system's `$PATH`.
- **Application won't open:** This installer includes a patch to clear stale locks during installation, but if an app refuses to open later, try running `pkill -f antigravity` to clear lingering background processes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
