#!/bin/bash

BREW_APPS=$(cat <<EOF
  argocd
  autoconf
  automake
  colima
  crane
  docker
  fzf
  gh
  gitsign
  gitsign-credential-cache
  gnused
  go
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

sudo -v

if [ ! -z $DEBUG ] ; then
    set -x
    set -e
fi

INSTALL='brew'

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

brew install $BREW_APPS

# Install go apps
go install github.com/justjanne/powerline-go
go install github.com/sigstore/cosign/cmd/cosign
go install github.com/golangci/golangci-lint/cmd/golangci-lint

