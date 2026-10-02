brew install git
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
echo -e '\nZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-completions
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
# Add to ~/.zshrc before sourcing oh-my-zsh:
# fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
# autoload -U compinit && compinit
# source $ZSH/oh-my-zsh.sh

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use

brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
# No needed, ghostty already provides what I want
# brew install tmux

brew install gh
#brew install git-crypt
brew install --cask ghostty
brew install --cask iterm2

# pyenv installation
# [more info](https://github.com/pyenv/pyenv)
brew install pyenv
brew install openssl@3 readline sqlite3 xz tcl-tk@8 libb2 zstd zlib pkgconfig
pyenv init --install
# To install a specific version of python, e.g. 3.14.8:
# pyenv latest -k 3
# pyenv install 3.14.8

# Java installation
# [more info](https://sdkman.io/install/)
curl -s https://get.sdkman.io | zsh
sdk install java
# brew install java
# brew install openjdk
# brew install openjdk@25
# brew install openjdk@21
# echo -e "\nexport JAVA_HOME=$(/usr/libexec/java_home -V 2>&1 | grep 25 | awk '{print $NF}')" >> ~/.zshrc

brew install --cask intellij-idea
brew install maven
brew install firefox
brew install openssh
brew install --cask breaktimer

# Tunnelblick is no longer needed
# brew install tunnelblick

brew install maccy
brew install monitorcontrol
brew install logseq
brew install Spotify
brew install netnewswire
brew install --cask logi-options+
brew install openshift-cli

# autocompletion openshift-cli
cat >>~/.zshrc<<EOF

# autocompletion for openshift cli
if [ oc ]; then
  source <(oc completion zsh)
  compdef _oc oc
fi
EOF

brew install hugo
brew install node
brew install gpg
brew install grep
echo -e '\n# added to use GNU grep with command grep instead of ggrep\nPATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"' >> ~/.zshrc
brew install coreutils
brew install helm

# used for cleaning git-crypt
brew install bfg

brew install --cask zen-browser
brew install --cask gimp
brew install --cask utm
brew install rclone
brew install pinentry
mkdir ~/.gnupg
echo "pinentry-program $(brew --prefix)/bin/pinentry" >> ~/.gnupg/gpg-agent.conf
echo 'use-agent' >> ~/.gnupg/gpg.conf
echo -e '\n# Allow GPG to Prompt with pinentry\nexport GPG_TTY=$(tty)' >>  ~/.zshrc

brew install ollama

brew install gnu-sed
brew install findutils

echo -e '\n# added to use gnu bin files in macOS\nPATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install git-filter-repo

# Usually, I don't use gitkraken much
# brew install --cask gitkraken

brew install git-gui
brew install act
brew install --cask nordvpn
brew install --cask session

# docker CLI installation
# brew install colima
# brew install docker
# brew install docker-buildx
# sudo ln -sf $HOME/.colima/default/docker.sock /var/run/docker.sock

# podman installation
# brew install podman

brew install --cask gcloud-cli
brew install --cask cyberduck
brew install --cask bitwarden

# AI
brew install nono
brew install anomalyco/tap/opencode-v2

brew install --cask gcloud-cli
gcloud init
