#!/usr/bin/env bash
# Provisions the Ansible control node
set -euo pipefail

LAB_USER=vagrant
LAB_HOME=/home/${LAB_USER}

install -d -m 700 -o "$LAB_USER" "$LAB_HOME/.ssh"
if [ -f /tmp/compliance_lab ]; then
    install -m 600 -o "$LAB_USER" -g "$LAB_USER" /tmp/compliance_lab "$LAB_HOME/.ssh/id_ed25519"
    install -m 644 -o "$LAB_USER" -g "$LAB_USER" /tmp/compliance_lab.pub "$LAB_HOME/.ssh/id_ed25519.pub"
    rm -f /tmp/compliance_lab
fi 