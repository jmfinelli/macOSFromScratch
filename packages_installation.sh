brew install git
brew install git-crypt
brew install --cask iterm2
brew install java
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
