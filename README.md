# dogfiles
this cowdog has dotfiles!

![hank the cowdog](http://2.bp.blogspot.com/-qsXKNYQ4xZc/TpfFkRYfcqI/AAAAAAAALbY/h8tydti83oA/s1600/hankthecowdog.gif)

## Setup
1. Make sure the init script is exectuable:
    ```shell
    chmod +x ./init.sh 
    ```

2. Run the init script
    This command will do the following:
      - install [oh-my-zsh](https://ohmyz.sh/#install) if it is not installed
      - install [Brew](https://docs.brew.sh/Installation) if it is not installed
      - run brew bundle
      - setup dotfiles
      - configure vscode

    To test out the scripts without overwriting existing dotfiles
    ```shell
    ./init.sh -t -t
    ```
    To run brew bundle, deploy the scripts to the home directory, and setup vscode
    ```shell
    ./init.sh
    ```
    
## Usage
Once the init scripts have been run, the files can be interacted with normally.  The added bonus is that there is an option to track the changes to files within the project. 
