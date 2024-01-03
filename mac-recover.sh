#!/bin/bash

# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Git
brew install git

# ClashX-Meta
brew install zuisong/tap/clashx-meta

# 安装 iterm2
brew install --cask iterm2

# 安装 aldente
brew install --cask aldente

# 安装 snipaste
brew install --cask snipaste

# 安装 maccy
brew install --cask maccy

# 安装 scroll-reverser
brew install --cask scroll-reverser

# 安装 oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# echo -e "ClashX.Meta: https://github.com/MetaCubeX/ClashX.Meta/releases"