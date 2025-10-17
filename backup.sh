rm -rf ~/backup
mkdir -p ~/backup

cp -r ~/.ssh ~/backup/ssh
cp -r ~/.gnupg ~/backup/gnup
cp ~/.gitconfig ~/backup/gitconfig
cp -r ~/.logseq ~/backup/logseq
cp ~/.vimrc ~/backup/vimrc
cp ~/.zshrc ~/backup/zshrc

# Take a copy of your feed from NetNewsWire
