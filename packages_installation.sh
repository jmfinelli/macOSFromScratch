brew install zsh
echo -e '\nZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
brew install git
brew install git-crypt
brew install --cask iterm2
brew install java
brew install openjdk
brew install openjdk@17
brew install openjdk@21
echo -e "\nexport JAVA_HOME=$(/usr/libexec/java_home -V 2>&1 | grep 17 | awk '{print $NF}')" >> ~/.zshrc
brew install --cask intellij-idea-ce
brew install maven
brew install firefox
brew install openssh
brew install openjdk@21
brew install stretchly
brew install tunnelblick
brew install maccy
brew install monitorcontrol
brew install logseq
brew install Spotify
brew install netnewswire
brew install logitech-options
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
brew install coreutils
brew install podman
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
echo -e '\n# added to use gnu sed with the sed command\nPATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.zshrc
