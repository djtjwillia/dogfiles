# dogfiles
this cowdog has dotfiles!
![hank the cowdog](http://2.bp.blogspot.com/-qsXKNYQ4xZc/TpfFkRYfcqI/AAAAAAAALbY/h8tydti83oA/s1600/hankthecowdog.gif)

## Setup

1. Install [oh-my-zsh](https://ohmyz.sh/#install), if it isn't already.  It can be installed via curl.  Refer to the linked documentation for more installation details.

    ```shell
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```
2. Install [Brew](https://docs.brew.sh/Installation), if it isn't already. It can be installed via curl.  Refer to the linked documentation for more installation details.

    ```shell
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

4. Install the brew bundle.
    
    Run brew bundle from within devops-dot-file project directory.
    ```shell
    brew bundle
    ```
    
5. Run the two init scripts in the devops-dot-files project.

    Scripts will need to have permissions modified so they can be ran.  The example commands below assume that they are being executed within the project directory.

    ```shell
    chmod +x ./scripts/init-dot-files.sh ./scripts/init-dot-dirs.sh
    ```
    To test out the scripts without overwriting existing dotfiles
    ```shell
    ./scripts/init-dot-files.sh -t; ./scripts/init-dot-dirs.sh -t
    ```
    To deploy the scripts to the home directory
    ```shell
    ./scripts/init-dot-files.sh -p; ./scripts/init-dot-dirs.sh -p
    ```
    
6. Run the setup script for vscode

    ```shell
    chmod +x ./scripts/init-vscode.sh
    ```
    To test out the scripts without overwriting existing settings
    ```shell
    ./scripts/init-vscode.sh -t
    ```
    To deploy the scripts to the home directory
    ```shell
    ./scripts/init-vscode.sh -p
    ```
    
## Usage
Once the init scripts have been ran, the files can be interacted with normally.  The added bonus is that there is an option to track the changes to files within the project. 
