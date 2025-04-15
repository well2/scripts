# 🧼 Brew Cleaner

**Simple Bash script to audit and optionally remove orphaned Homebrew packages on macOS.**  
It helps you clean up packages that were installed as dependencies but are no longer needed.

---

## 🧠 What does it do?

- Lists all installed Homebrew formulae.
- Identifies the ones you installed directly (`brew leaves`).
- Gathers all dependencies of those formulae.
- Detects "orphaned" formulae (i.e., not installed by you and not required by anything else).
- Gives you the option to uninstall them safely.

---

## ⚙️ Requirements

- macOS with [Homebrew](https://brew.sh) installed.

---

## 🚀 Usage

1. Clone this repo:

    ```bash
    git clone https://github.com/well2/scripts.git
    cd brew-cleaner
    ```

2. Make the script executable:

    ```bash
    chmod +x audit_orphaned_brews.sh
    ```

3. Run the audit:

    ```bash
    ./audit_orphaned_brews.sh
    ```

---

## 🔐 Safety

This script only reads your installed packages and dependencies.  
You will be **explicitly asked for confirmation** before anything is removed.

---

## 📄 License

MIT – free to use, modify, and share.

---

## 🤝 Contributing

Feel free to open issues or submit pull requests with improvements or ideas!
