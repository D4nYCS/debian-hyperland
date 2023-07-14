#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# Installing Essential Programs 
nala install kitty thunar unzip wget -y
# Installing Other less important Programs
nala install lightdm xrdp kde-plasma-desktop tmux -y

# Install chrome-browser
nala install apt-transport-https curl -y
curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
nala update
nala install google-chrome-stable -y

# Enable graphical login, change target from CLI to GUI and Remote Login
systemctl enable lightdm
systemctl set-default graphical.target
systemctl enable xrdp

# System Policy Prevents Popup fix
echo "[Network Manager all Users]" >> /etc/polkit-1/localauthority/50-local.d/50-allow-network-manager.pkla
echo "Identity=unix-user:*" >> /etc/polkit-1/localauthority/50-local.d/50-allow-network-manager.pkla
echo "Action=org.freedesktop.NetworkManager.settings.modify.system;org.freedesktop.NetworkManager.network-control" >> /etc/polkit-1/localauthority/50-local.d/50-allow-network-manager.pkla
echo "ResultAny=no" >> /etc/polkit-1/localauthority/50-local.d/50-allow-network-manager.pkla
echo "ResultInactive=no" >> /etc/polkit-1/localauthority/50-local.d/50-allow-network-manager.pkla
echo "ResultActive=yes" >> /etc/polkit-1/localauthority/50-local.d/50-allow-network-manager.pkla

# Use nala
bash scripts/usenala
