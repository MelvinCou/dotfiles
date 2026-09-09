# Dotfiles

- Linux (Debian, Arch)
    - zsh, oh my zsh, powerlevel10k
    - basic vim configuration
- Windows
    - oh my posh
    - WSL with Arch (which runs chezmoi again...) ❌ not tested

All installed packages are available at [packages.yaml](./home/.chezmoidata/packages.yaml)

Run the script :

```sh
# Linux
sh -c "$(curl -fsLS get.chezmoi.io)" -- init -ad 1 MelvinCou
# Windows
winget install -e --accept-source-agreements --accept-package-agreements --scope CurrentUser twpayne.chezmoi
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
chezmoi init -ad 1 MelvinCou
```
