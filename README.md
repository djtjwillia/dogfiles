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

3. Install the init script. 
   (This will run brew bundle, the dotfiles setup, and setup vscode).

    ```shell
    chmod +x ./scripts/init.sh 
    ```
    To test out the scripts without overwriting existing dotfiles
    ```shell
    ./scripts/init.sh -t;
    ```
    To run brew bundle, deploy the scripts to the home directory, and setup vscode
    ```shell
    ./scripts/init.sh
    ```
    
## Usage
Once the init scripts have been run, the files can be interacted with normally.  The added bonus is that there is an option to track the changes to files within the project. 
