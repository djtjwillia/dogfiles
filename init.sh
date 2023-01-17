if [ -d ~/.oh-my-zsh ]; then
    echo "oh-my-zsh is installed"
else
    echo "oh-my-zsh is not installed"
fi

if ! command -v brew &> /dev/null
then
    echo "brew could not be found, installing"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "brew is installed"
fi

# brew bundle
chmod +x  ./scripts/init-dot-files.sh ./scripts/init-vscode.sh
./scripts/init-dot-files.sh $1; ./scripts/init-vscode.sh $2
