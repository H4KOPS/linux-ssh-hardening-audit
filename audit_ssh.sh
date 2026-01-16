#!/bin/bash
# -----------------------------------------
# SSH Hardening Audit Script
# Checks basic SSH security settings + UFW
# -----------------------------------------

SSH_CONFIG="/etc/ssh/sshd_config"

# Simple colored output
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

print_ok()   { echo -e "${GREEN}[OK]${RESET}   $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
print_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }

echo "======================================"
echo "     🔐 SSH Hardening Audit Report"
echo "======================================"

# 1) Check if SSH config file exists
if [ ! -f "$SSH_CONFIG" ]; then
  print_warn "I can't find $SSH_CONFIG (SSH may not be installed)."
  exit 1
fi

# Helper function:
# Reads the LAST active value of a setting from sshd_config
# Example: get_value "PasswordAuthentication"
get_value() {
  local key="$1"

  # We ignore commented lines (#) and take the last matching line
  grep -i "^[[:space:]]*$key" "$SSH_CONFIG" 2>/dev/null | tail -n 1 | awk '{print $2}'
}

# 2) Root login check
root_login=$(get_value "PermitRootLogin")

if [ "$root_login" = "no" ]; then
  print_ok "Root login is disabled (PermitRootLogin no)."
else
  print_warn "Root login is NOT clearly disabled (PermitRootLogin = ${root_login:-default})."
  print_info "Recommendation: set PermitRootLogin no"
fi

# 3) Password login check
password_auth=$(get_value "PasswordAuthentication")

if [ "$password_auth" = "no" ]; then
  print_ok "Password login is disabled (PasswordAuthentication no)."
else
  print_warn "Password login is NOT clearly disabled (PasswordAuthentication = ${password_auth:-default})."
  print_info "Recommendation: set PasswordAuthentication no"
fi

# 4) Public key authentication check
pubkey_auth=$(get_value "PubkeyAuthentication")

if [ "$pubkey_auth" = "yes" ]; then
  print_ok "Public key login is enabled (PubkeyAuthentication yes)."
else
  print_warn "Public key authentication is not explicitly enabled (PubkeyAuthentication = ${pubkey_auth:-default})."
  print_info "Recommendation: set PubkeyAuthentication yes"
fi

# 5) SSH Port info (not always required to change, but good to know)
ssh_port=$(get_value "Port")
print_info "SSH is running on port: ${ssh_port:-22 (default)}"

# 6) Check if SSH service is running
if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
  print_ok "SSH service is running."
else
  print_warn "SSH service is NOT running (or not found)."
fi

# 7) Check UFW firewall status
if command -v ufw >/dev/null 2>&1; then
  # First line usually looks like: "Status: active"
  ufw_status=$(sudo ufw status | head -n 1)

  if echo "$ufw_status" | grep -qi "active"; then
    print_ok "UFW firewall is active."
  else
    print_warn "UFW is installed but NOT active."
    print_info "Enable it using: sudo ufw enable"
  fi
else
  print_warn "UFW is not installed."
  print_info "Install it using: sudo apt install ufw -y"
fi

echo "======================================"
echo "     ✅ Audit finished successfully"
echo "======================================"
