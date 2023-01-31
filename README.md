# dogfiles

this cowdog has dotfiles!

![hank the cowdog](http://2.bp.blogspot.com/-qsXKNYQ4xZc/TpfFkRYfcqI/AAAAAAAALbY/h8tydti83oA/s1600/hankthecowdog.gif)

## Setup

1. Setup your variables:
   a. Go into playbook.yml and fill in gitconfig and sshconfig.
   b. Fill in username and email in roles/macbook/files/gitconfig
   **Note: You will not want to commit your changes to these two files!"**

2. Make sure the init script is exectuable:

   ```shell
   chmod +x ./init.sh
   ```

3. Run the init script
   This command will do the following:
   - install [oh-my-zsh](https://ohmyz.sh/#install) if it is not installed
   - install [Brew](https://docs.brew.sh/Installation) if it is not installed
   - run brew bundle
   - setup dotfiles
   - configure vscode

## Usage

Once the init script has been run, the files can be interacted with normally. The added bonus is that there is an option to track the changes to files within the project. The recommended use is to not manually interact with these files, instead keep this repo up to date and use it to manage all your config.

## Apps under consideration:

- Wally
- Flux
- Krisp
- AWS VPN
- Intellij
- Gather
- Postman
