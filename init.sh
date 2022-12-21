#!/bin/bash

BREW_APPS=$(cat <<EOF
  argocd
  autoconf
  automake
  clusterctl
  colima
  crane
  docker
  freeida
  fzf
  gh
  gitsign
  gitsign-credential-cache
  gnu-sed
  golang
  gron
  grpcurl
  helm
  jq
  kind
  kns
  ko
  kubernetes-cli
  kube-ps1
  kustomize
  mtr
  node
  nmap
  opa
  openssl@3
  packer
  protobuf
  protoc-gen-go
  protoc-gen-go-grpc
  qemu
  ripgrep
  rustup-init
  slack
  stern
  syft
  tldr
  tree
  watch
  wget
  yq
  zsh-syntax-highlighting
EOF
)

BREW_CASKS=$(cat <<EOF
  hermes
  homebrew/cask-fonts/font-source-code-pro-for-powerline
EOF
)

sudo -v

if [ ! -z $DEBUG ] ; then
    set -x
    set -e
fi

#
# Link all the dotfiles to homedir
#
DOTFILES_DIR="$HOME/src/dotfiles";
EXCLUDE='(setterupper|README|lock|#|\.Trash|^\.git)'

cd $HOME
for i in $(ls -a $DOTFILES_DIR | egrep -v "$EXCLUDE" | egrep -v "^\.+$") ; do
    if [ ! -d $HOME/$i ] ; then
        CMD="ln -nfs $DOTFILES_DIR/$i"
    fi
    if [ -z $DEBUG ] ; then
        $($CMD)
    else
        echo "$CMD"
    fi
done

# Create new SSH key if not exists
if [ ! -f ~/.ssh/ed25519 ]; then
  ssh-keygen -t ed25519
fi

# Install XCode CLI Tools
sudo xcode-select --install

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Homebrew and some packages
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ ! -f ~/.brewhub ] ; then
    echo "\n\n"
    echo "You must reate a personal access token:"
    echo "https://github.com/settings/tokens/new?scopes=gist,public_repo&description=Homebrew"
    echo "Enter Github Token for Homebrew: "
    read github_key
    echo "export HOMEBREW_GITHUB_API_TOKEN='$github_key'" > ~/.brewhub
    source ~/.brewhub
fi

brew tap anchore/syft
brew tap blendle/blendle
brew tap sigstore/tap

brew install $BREW_APPS
brew install $BREW_CASKS --cask

# Setup git global config including to gitsign all the things
git config --global user.name "Ryan Hartje"
git config --global user.email ryan@ryanhartje.com
git config --global commit.gpgsign true  # Sign all commits
git config --global tag.gpgsign true  # Sign all tags
git config --global gpg.x509.program gitsign  # Use gitsign for signing
git config --global gpg.format x509  # gitsign expects x509 args
git config pull.rebase true

# Setup Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin

gsed -i 's|plugins=(|plugins=(zsh-autosuggestions |g' $HOME/.zshrc
gsed -i 's|plugins=(|plugins=(fzf-zsh-plugin |g' $HOME/.zshrc
gsed -i 's|plugins=(|plugins=(kube-ps1 |g' $HOME/.zshrc

# Install go apps
go install github.com/justjanne/powerline-go
go install github.com/sigstore/cosign/cmd/cosign
go install github.com/golangci/golangci-lint/cmd/golangci-lint


# kubernerdies
## install tilt
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash


# Setup kube-ps1
echo "PROMPT=\`kube_ps1\`\$PROMPT" >> $HOME/.zshrc
echo >> $HOME/.zshrc
