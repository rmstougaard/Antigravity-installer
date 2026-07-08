# Contributing to Antigravity Community Installer

First off, thank you for taking the time to contribute! 🎉

This is a community-driven project designed to make installing and managing the Antigravity product suite on Linux as easy as possible. We welcome contributions of all kinds: bug fixes, feature suggestions, documentation updates, and improved terminal UI/UX.

---

## How to Contribute

### 1. Reporting Bugs & Issues
If you encounter a bug, please check the [existing issues](https://github.com/rmstougaard/Antigravity-installer/issues) first to see if it has already been reported. If not, open a new issue and include:
- Your Linux distribution (e.g., Ubuntu 22.04, Fedora 39, Arch Linux).
- The version of the installer you used.
- Clear steps to reproduce the problem.
- Terminal output logs (if any).

### 2. Suggesting Enhancements
We welcome ideas for new features or interactive CLI improvements! Please open an issue describing:
- The problem you want to solve.
- How you envision the feature working.
- Any mockups, flow descriptions, or example commands.

### 3. Submitting Pull Requests (PRs)
Ready to make a change? Excellent! Here is the workflow to follow:

1. **Fork the repository** and clone it locally.
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-awesome-feature
   ```
3. **Make your changes** and keep the coding style consistent.
4. **Test your script locally** to ensure it works across different scenarios.
5. **Commit your changes** with a clear, descriptive message:
   ```bash
   git commit -m "feat: add support for custom installation directory"
   ```
6. **Push to your fork** and open a Pull Request against our `main` branch.

---

## Coding Guidelines

Since this installer is written entirely in Bash (`install.sh`), we strive to keep it clean, robust, and portable across Linux environments.

### Bash Best Practices
- **Linting:** Run [ShellCheck](https://www.shellcheck.net/) on `install.sh` before submitting. Your PR should not introduce any new ShellCheck warnings.
- **Safety First:** We use `set -e` at the top of the script. Ensure any command that is expected to fail occasionally has a proper fallback (e.g., `command || true`).
- **Quote Variables:** Always double-quote variable expansions to handle spaces safely (e.g., Use `"$TMP_DIR"` instead of `$TMP_DIR`).
- **Terminal UI / States:**
  - If you modify cursor visibility (using `tput civis`), make sure you register a `trap` to restore it on exit/termination (`tput cnorm`), preventing users' terminals from getting messed up on `Ctrl+C`.
  - Keep colors and UI indicators consistent (use green `[✓]` for success, yellow `[*]`/`[-]` for info/warning, red `[X]` for error).
- **Cleanup:** Always clean up temporary resources in `/tmp/` before the script exits.

---

## Local Testing

Before submitting a Pull Request, run the script in a test environment or sandbox if possible. 

> [!WARNING]
> **Be cautious with Phase 1 (Purge/Wipe System) testing**! Running a purge might delete files and configs from your own local Antigravity installation. We recommend manually bypassing or testing this in a VM/container unless you explicitly want to wipe your local environment.

You can dry-run specific logic segments or test component downloads by placing temporary mock directories in `/tmp/`.

---

## License

By contributing to this repository, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
