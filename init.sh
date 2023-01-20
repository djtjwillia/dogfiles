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

brew bundle

chmod +x ./playbook.yml
ansible-playbook playbook.yml -i inventory
