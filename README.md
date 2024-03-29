# dogfiles

this cowdog has dotfiles!

![hank the cowdog](http://2.bp.blogspot.com/-qsXKNYQ4xZc/TpfFkRYfcqI/AAAAAAAALbY/h8tydti83oA/s1600/hankthecowdog.gif)

## Setup

1. Setup your ssh keys.
   a. make sure your ssh keys are generated
   b. make sure your signing keys are generated.
   c. if using separate signing keys from your auth keys,
   make sure to add them to the ssh agent using `ssh-add`

2. Setup your variables:
   a. Go into playbook.yml and fill in gitconfig and sshconfig.
   b. Fill in username and email in roles/macbook/files/gitconfig
   **Note: You will not want to commit your changes to these two files!"**

3. Make sure the init script is exectuable:

```shell
  chmod +x ./init.sh
```

4. Run the init script
   This command will do the following:

   - install [oh-my-zsh](https://ohmyz.sh/#install) if it is not installed
   - install [Brew](https://docs.brew.sh/Installation) if it is not installed
   - run brew bundle
   - setup dotfiles
   - configure vscode

5. Do some manual config/fixing.

Terminal:

- Open iTerm2, under `iTerm2` in the menu bar, select `Make iTerm2 Default Term`

NPM:

- `nvm install --lts`
- `nvm use v18.14.0`

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
