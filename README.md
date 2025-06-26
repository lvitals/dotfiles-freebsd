# Dotfiles for FreeBSD

These are my personal dotfiles and setup scripts for FreeBSD systems.

## Features

*   Copies config files to `/etc`, `/boot`, and `$HOME` 
*   Restores `~/.config` (e.g. `sway`, `rofi`, `alacritty`)
*   Installs packages listed in `pkg/<hostname>.txt`
*   Uses `doas` or `sudo` automatically
    

## Usage

```
git clone https://github.com/lvitals/dotfiles-freebsd.git
cd dotfiles
./install.sh
```

The script will detect your hostname and apply the correct configs.

## Structure

```
etc/           → /etc 
boot/          → /boot 
home/          → $HOME and ~/.config 
pkg/<host>.txt → pkg packages per host
install.sh     → setup script
```

## Requirements

*   FreeBSD 13 or 14   
*   `pkg` (package manager)
*   `sudo` or `doas`

- - -