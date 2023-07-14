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
nala install kitty thunar unzip wget xorgrdp -y
# Installing Other less important Programs
nala install lightdm xrdp kde-plasma-desktop -y

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

# Use nala
bash scripts/usenala
