#!/bin/bash

# Get font for powerlevel10k
set  -euo pipefail
I1FS=$'\n\t'
echo "Installing MesloGS font"
fontpath="${XDG_DATA_HOME:-$HOME/.local/share}"/fonts/MesloGS
mkdir -p $fontpath && cd $fontpath
wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -f

echo "Installing packages"
sudo apt update -qq
sudo apt install -qqq --no-install-recommends zsh zsh-antigen bat
