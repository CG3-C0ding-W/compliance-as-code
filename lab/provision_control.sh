#!/usr/bin/env bash
# Provisions the Ansible control node. Run by Vagrant as root; safe to re-run.
set -euo pipefail

LAB_USER=vagrant
LAB_HOME=/home/${LAB_USER}

# --- Lab SSH key -------------------------------------------------------------
# The private key lets this VM reach the Rocky targets.
# The public key lets Windows (VS Code Remote-SSH) log in to this VM.

install -d -m 700 -o "$LAB_USER" "$LAB_HOME/.ssh"
if [ -f /tmp/compliance_lab ]; then
    install -m 600 -o "$LAB_USER" -g "$LAB_USER" /tmp/compliance_lab "$LAB_HOME/.ssh/id_ed25519"
    install -m 644 -o "$LAB_USER" -g "$LAB_USER" /tmp/compliance_lab.pub "$LAB_HOME/.ssh/id_ed25519.pub"
    rm -f /tmp/compliance_lab
fi 

AUTH="$LAB_HOME/.ssh/authorized_keys"
touch "$AUTH"
grep -qxF "$(cat "$LAB_HOME/.ssh/id_ed25519.pub")" "$AUTH" || cat "$LAB_HOME/.ssh/id_ed25519.pub" >> "$AUTH"
chown "$LAB_USER:$LAB_USER" "$AUTH"
chmod 600 "$AUTH"
rm -f /tmp/compliance_lab.pub

# --- System packages -----------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
apt-get update -q 
apt-get install -y -q python3-venv git podman gh

# --- Ansible tooling in a virtualenv owned by the lab user ---------------------
sudo -u "$LAB_USER" -H bash <<'USER_SETUP'
set -euo pipefail
[ -d ~/.venvs/ansible ] || python3 -m venv ~/.venvs/ansible
~/.venvs/ansible/bin/pip install -q --upgrade pip
~/.venvs/ansible/bin/pip install -q ansible-core ansible-lint ansible-navigator ansible-builder
LINE='source ~/.venvs/ansible/bin/activate'
grep -qxF "$LINE" ~/.bashrc || echo "$LINE" >> ~/.bashrc
git config --global core.autocrlf input
USER_SETUP

echo "control node ready"