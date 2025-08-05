#!/bin/bash
set -e

# This file is to add and compile chtek, the latex linter
printf "Are you sure you want to install it? (Read the text) [y/N] "
read REPLY
[[ "$REPLY" =~ ^[Yy]$ ]] || exit 1

# Variables
CHKURL="https://git.savannah.nongnu.org/cgit/chktex.git"
INSTALL_PREFIX="/usr/local"
CHKTEXRC_PATH="$INSTALL_PREFIX/etc/chktexrc"

# Check for required commands
for cmd in git autoconf automake make gcc; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed. Please install it first." >&2
    exit 1
  fi
done

# Create a temp dir
TMPDIR=$(mktemp -d)
echo "Using temp directory: $TMPDIR"
cd "$TMPDIR"

# Clone the chktex repo
git clone "$CHKURL" chktex-src
cd chktex-src

# Generate configure script
./autogen.sh

# Configure the build
./configure --prefix="$INSTALL_PREFIX"

# Build and install
make -j"$(nproc)"
sudo make install

# Add CHKTEXRC environment variable if not already set
add_env_var() {
  local shellrc="$1"
  local line="export CHKTEXRC=$CHKTEXRC_PATH"
  if ! grep -qxF "$line" "$shellrc" 2>/dev/null; then
    echo "$line" >> "$shellrc"
    echo "Added CHKTEXRC to $shellrc"
  else
    echo "CHKTEXRC already set in $shellrc"
  fi
}

add_env_var "$HOME/.bashrc"
add_env_var "$HOME/.zshrc"

# Clean up temp dir
rm -rf "$TMPDIR"

echo "chktex installed successfully!"
echo "Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc' to load CHKTEXRC."

