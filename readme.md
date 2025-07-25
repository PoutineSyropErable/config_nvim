# Screenshots

Here's a screenshots with some stuff toggled on:
(The undo tree, and nvim tree file manager), though it also supports telescope's file manager, and lf

Example of the things you can toggle (a terminal, a file manager tree, and a undo tree [There's more])
![Screenshots example of toggle-able](./screenshots.png)

Example of autocompletion
![Example of autocomplete](./zzz_auto_complete.png)

Example of a debugger
![Example of Debugger](./zz_debugger.png)

# Installation

how to install:

```bash
# Ensure the logs directory exists
mkdir -p ~/.config/nvim_logs

# Backup existing ~/.config/nvim if it exists, using numbered backups (~1, ~2, etc.)
[ -d ~/.config/nvim ] && mv --backup=numbered ~/.config/nvim ~/.config/nvim_backup

# Clone the Neovim configuration repository
git clone https://github.com/PoutineSyropErable/config_nvim ~/.config/nvim

```

Packages to install:

On Arch: (Use Paru or whatever else if thats what you are using. Though if you are on arch you probably dont need my help lol)

```bash
# Install system packages from the official Arch repositories
sudo pacman -S --needed clang rust-analyzer ruby npm nodejs prettier \
python-pip python-virtualenv flake8 lua-language-server bash-language-server go \
clang-tools-extra python-debugpy python-isort python-pylint

# Install JDTLS from AUR
yay -S --needed jdtls

# Install TypeScript LSP (tsserver) and Tailwind CSS LSP
npm install -g typescript typescript-language-server tailwindcss

# Install Ruby LSP (Solargraph) via gem (since it's NOT in AUR)
gem install solargraph

# Install Hyprland LSP (Hyprls) via Go (since it's NOT in AUR)
go install github.com/hyprland-community/hyprls/cmd/hyprls@latest


```

---

On MacOS:
Note: I don't have a mac, so it might not work perfectly, in which case we'll need to go and find out which package manager gives them

```bash
# Install system packages, Core LSP and dependencies
brew install clang-format rust-analyzer ruby npm node prettier \
python@3.11 lua-language-server \
bash-language-server jdtls go

# Install additional Python tools
pip3 install debugpy flake8 isort mypy pylint ruff black

# Install Solargraph (Ruby LSP)
gem install solargraph

# Install Hyprland LSP (may require manual compilation)
brew install hyprland-lsp
```

Here's another list, in case the previous one didn't work. If not, we'll have to merge and modify them

```bash
# Install system packages, Core LSP and dependencies
brew install clang-format rust-analyzer ruby npm node prettier \
python@3.11 lua-language-server bash-language-server go jdtls

# Install TypeScript LSP (tsserver) and Tailwind CSS LSP
npm install -g typescript typescript-language-server tailwindcss

# Install Ruby LSP (Solargraph)
gem install solargraph

# Install Hyprland LSP (Hyprls) via Go
go install github.com/hyprland-community/hyprls/cmd/hyprls@latest


```

Install commands from inside neovim:

```bash
:MasonInstall lua_ls solargraph tsserver pyright clangd rust_analyzer \
bash-language-server jdtls gopls tailwindcss hyprls
```

```bash
:MasonInstall black debugpy flake8 isort mypy pylint ruff \
prettier clang-format
```

Go compile scripts/find_project_root
using the build.sh script
Since its not tracked anymore
