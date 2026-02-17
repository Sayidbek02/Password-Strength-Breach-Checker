# Password-Strength-Breach-Checker
Validates password security using:  Length check  Special character check  Upper/lowercase validation  Numeric character check  Dictionary word detection  Brute-force time estimation  Helps users evaluate password strength and identify potential security risks before real-world use.

---

# Password Strength & Breach Checker

**Version:** 1.0.0
**Language:** Bash Script

A professional Bash tool for checking password security.

---

## ✨ Features

### Core Checks

* ✅ **Length validation** – Evaluates password length
* ✅ **Upper/Lowercase check** – Verifies letter case presence
* ✅ **Number validation** – Detects numeric characters
* ✅ **Special characters** – Checks for symbols like `!@#$%^&*`
* ✅ **Dictionary check** – Detects common words
* ✅ **RockYou wordlist** – Compares against known password database
* ✅ **Entropy calculation** – Measures mathematical complexity
* ✅ **Brute-force estimation** – Estimates cracking time

### Additional Capabilities

* 🎨 **Colored interface** – Clean output using ANSI colors
* 📊 **Strength rating** – WEAK / MEDIUM / STRONG evaluation
* 💡 **Recommendations** – Suggestions to improve password strength
* 📝 **Logging** – All checks saved to log file
* 🔒 **Security** – Logs readable by root only
* ⚙️ **Config file** – Customizable settings
* 🛡️ **Error handling** – Robust error management
* ⌨️ **Signal handling** – Proper Ctrl+C handling

---

## 📋 Requirements

### Shell

```bash
Bash 4.0+
```

### Additional Dependencies

```bash
# Standard Unix tools (usually pre-installed):
- grep
- bc (for mathematical calculations)
- sha256sum (for hashing)
```

### Optional

```bash
# Colored output (ANSI codes enabled automatically)

# Install bc if missing:
sudo apt-get install bc     # Debian/Ubuntu
sudo yum install bc         # CentOS/RHEL
brew install bc             # macOS
```

---

## 🚀 Installation

### 1. Download the script

```bash
# Using Git
git clone <repository-url>
cd password-checker

# Or direct download
wget <script-url>/password_checker.sh
```

### 2. Install bc (if not installed)

```bash
# Debian/Ubuntu
sudo apt-get install bc

# CentOS/RHEL
sudo yum install bc

# macOS
brew install bc
```

### 3. Make scripts executable

```bash
chmod +x password_checker.sh
chmod +x install.sh
chmod +x demo.sh
```

### 4. Run the script

```bash
./password_checker.sh
```

---

## 💻 Usage

### Interactive Mode (Recommended)

```bash
./password_checker.sh
```

### Using Arguments

```bash
# Help
./password_checker.sh --help

# Version
./password_checker.sh --version

# Provide password (NOT secure!)
./password_checker.sh -p "MyP@ssw0rd123"
```

---

## 📖 Examples

### Example 1: Weak Password

```bash
$ ./password_checker.sh
[+] Enter password (hidden):

============================================================
PASSWORD ANALYSIS
============================================================

CHECKS:
------------------------------------------------------------
✗ Length              : Too short (minimum 8 characters)
✗ Uppercase           : No uppercase letters
✓ Lowercase           : 8 lowercase letters
✗ Numbers             : No digits
✗ Special             : No special characters (!@#$%^&*)
✗ Dictionary          : Found in common password list!
◐ Entropy             : 18.8 bits

RESULT:
------------------------------------------------------------
Score: 20.5%
Strength: WEAK
Crack Time: < 1 second

RECOMMENDATIONS:
------------------------------------------------------------
• Use at least 12 characters
• Add uppercase letters (A-Z)
• Add numbers (0-9)
• Add special characters (!@#$%^&*)
• Avoid common words
```

---

### Example 2: Strong Password

```bash
$ ./password_checker.sh
[+] Enter password (hidden):

============================================================
PASSWORD ANALYSIS
============================================================

CHECKS:
------------------------------------------------------------
✓ Length              : Excellent length
✓ Uppercase           : 3 uppercase letters
✓ Lowercase           : 7 lowercase letters
✓ Numbers             : 4 digits
✓ Special             : 3 special characters
✓ Dictionary          : No dictionary word found
✓ Entropy             : 95.2 bits

RESULT:
------------------------------------------------------------
Score: 94.8%
Strength: STRONG
Crack Time: 1.2e+15 years
```

---

## ⚙️ Configuration

The `config.conf` file is created automatically:

```ini
[Settings]
min_length = 8
require_uppercase = true
require_lowercase = true
require_numbers = true
require_special = true
wordlist_path = rockyou.txt
log_enabled = true

[Scoring]
length_weight = 2
uppercase_weight = 1
lowercase_weight = 1
number_weight = 1
special_weight = 2
entropy_weight = 3
```

---

## 📁 File Structure

```
password-checker/
├── password_checker.sh
├── config.conf
├── requirements.txt
├── README.md
├── rockyou.txt
├── install.sh
├── demo.sh
└── password_checker.log
```

---

## 📊 Log File

Log file is stored at `/var/log/password_checker.log` (or current directory if permission denied).

### Security

* Log file readable by root only (0600 permissions)
* Passwords stored as SHA-256 hashes
* Plain-text passwords are never logged

**Log format:**

```
2024-01-15 14:30:45 - INFO - Password checked - Hash: a1b2c3d4e5f6g7h8, Score: 85.5%, Strength: STRONG
```

---

## 🔐 Security Best Practices

1. Use interactive mode (avoid passing passwords as arguments)
2. Download RockYou wordlist for better detection
3. Protect log files (600 permissions)
4. Secure config file if storing sensitive settings

---

## 🎯 Scoring System

### Strength Levels

| Level  | Score   | Description       |
| ------ | ------- | ----------------- |
| WEAK   | 0-39%   | Easily crackable  |
| MEDIUM | 40-69%  | Needs improvement |
| STRONG | 70-100% | Secure password   |

### Entropy Levels

| Entropy     | Security    |
| ----------- | ----------- |
| < 28 bits   | Very weak   |
| 28–35 bits  | Weak        |
| 36–59 bits  | Moderate    |
| 60–127 bits | Strong      |
| 128+ bits   | Very strong |

---

## 📝 License

MIT License – Free to use.

---

## 👨‍💻 Sayidbek Ibrokhimov

Security Tool Developer

---

## 🤝 Contributing

1. Fork the project
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

**Note:** This tool is for educational purposes only. Use caution when testing real passwords.
