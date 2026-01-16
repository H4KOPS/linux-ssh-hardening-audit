# 🔐 Linux SSH Hardening Audit Script

A simple Bash script that audits common SSH hardening settings on Linux systems.

## ✅ Checks Included
- PermitRootLogin (root login disabled)
- PasswordAuthentication (password login disabled)
- PubkeyAuthentication (key auth enabled)
- SSH Port info
- UFW firewall status
- SSH service status

## 🚀 Run
```bash
chmod +x audit_ssh.sh
sudo ./audit_ssh.sh

# save & exit
