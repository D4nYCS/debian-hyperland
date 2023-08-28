#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# Installing Essential Programs 
nala install -y meson wget build-essential ninja-build cmake-extras cmake gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev libvulkan-volk-dev  vulkan-validationlayers-dev libvkfft-dev libgulkan-dev libegl-dev libgles2 libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xinput-dev libpango1.0-dev xdg-desktop-portal-wlr hwdata check libgtk-3-dev libsystemd-dev xwayland kitty

#Create Directory, download source and excract 
mkdir -p /home/$username/hyprland
cd /home/$username/hyprland
wget https://github.com/hyprwm/Hyprland/releases/download/v0.28.0/source-v0.28.0.tar.gz
tar -xvf source-v0.28.0.tar.gz
wget https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.31/downloads/wayland-protocols-1.32.tar.xz
tar -xvJf wayland-protocols-1.32.tar.xz
wget https://gitlab.freedesktop.org/wayland/wayland/-/releases/1.22.0/downloads/wayland-1.22.0.tar.xz
tar -xzvJf wayland-1.22.0.tar.xz
wget https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/0.1.1/downloads/libdisplay-info-0.1.1.tar.xz
tar -xvJf libdisplay-info-0.1.1.tar.xz
git clone https://gitlab.freedesktop.org/emersion/libliftoff.git
git clone https://gitlab.freedesktop.org/libinput/libinput.git

cd wayland-1.22.0
mkdir build &&
cd    build &&
eson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -Ddocumentation=false &&
ninja
ninja install
cd ../..

cd wayland-protocols-1.31

mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release &&
ninja

ninja install

cd ../..

chmod a+rw hyprland-source
cd hyprland-source/

sed -i 's/\/usr\/local/\/usr/g' config.mk
make install

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

rm -rf $builddir