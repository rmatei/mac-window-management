ln -sf "/Users/rcm/Library/Mobile Documents/com~apple~CloudDocs/" ~/Drive
ln -sf ~/Drive/Code/Hammerspoon ~/.hammerspoon

# If ~./inputrc doesn't exist yet, first include the original /etc/inputrc so we don't override it
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi

# Add option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc


# Git setup
git config --global user.name "Robert Cezar Matei"
git config --global user.email "rmatei@gmail.com"
git config --global credential.helper osxkeychain
