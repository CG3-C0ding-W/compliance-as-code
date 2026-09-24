#!/usr/bin/env bash
# Provisions a Rocky Linux target: trusts the lab key so the control node can log in.
# Run by Vagrant as root; safe to re-run.
set -euo pipefail

LAB_USER=vagrant
AUTH=/home/${LAB_USER}/.ssh/authorized_keys

install -d -m 700 -o "$LAB_USER"  -g "$LAB_USER" "/home/${LAB_USER}/.ssh"
touch $AUTH
grep -qxF "$(cat /tmp/compliance_lab.pub)" "$AUTH" || cat /tmp/compliance_lab.pub >> "$AUTH"
chown "$LAB_USER:$LAB_USER" "$AUTH"
chmod 600 "$AUTH"
restorecon -R "/home/${LAB_USER}/.ssh" 2>/dev/null || true   
rm -f /tmp/compliance_lab.pub

echo "$(hostname) ready"