# dogfiles

this cowdog has dotfiles!

![hank the cowdog](http://2.bp.blogspot.com/-qsXKNYQ4xZc/TpfFkRYfcqI/AAAAAAAALbY/h8tydti83oA/s1600/hankthecowdog.gif)

## Setup

1. Install [go-task](https://taskfile.dev/) (e.g., `brew install go-task/tap/go-task`). The provisioning workflow now uses `task init` under the hood.

2. Setup your ssh keys.
   a. make sure your ssh keys are generated
   b. make sure your signing keys are generated.
   c. if using separate signing keys from your auth keys,
   make sure to add them to the ssh agent using `ssh-add`

3. Setup your variables:
   a. Copy `env/.env.example` to `.env` and fill in persona-specific git + ssh values (kept untracked).
   b. Until the migration fully lands, you can still adjust `playbook.yml`/`roles/macbook/files/gitconfig` for the Ansible fallback.
   **Note: Never commit your `.env` or personalized git/ssh files!**

4. Make sure the init script is exectuable:

```shell
  chmod +x ./init.sh
```

5. Run the init script (or invoke `task init` directly)
   This command will do the following:

   - install [oh-my-zsh](https://ohmyz.sh/#install) if it is not installed
   - install [Brew](https://docs.brew.sh/Installation) if it is not installed
   - install go-task (via Homebrew) if it is not installed
   - run `brew bundle`
   - sync top-level `dotfiles/` into `~/.dotfiles`
   - render `templates/*.tmpl` (zshrc, git, ssh) using values from `.env`
   - configure Windsurf by copying everything under `windsurf/` into `~/Library/Application Support/Windsurf/User/`

   Pass persona + safety flags as env vars, e.g. `PERSONA=work DRY_RUN=true task init`.

6. Do some manual config/fixing.

Terminal:

- Open iTerm2, under `iTerm2` in the menu bar, select `Make iTerm2 Default Term`

NPM:

- `nvm install --lts`
- `nvm use v18.14.0`

Tailscale:
Download and install Tailscale.

## Usage

Once the init script has been run, you can re-use the Taskfile commands at any time:

- `task init` – full bootstrap.
- `DRY_RUN=true task init` – print everything that *would* run without changing your system.
- `PERSONA=personal|work|both task init` – choose which git/ssh identities to render.
- `task dotfiles:sync` / `task dotfiles:pull` – push or pull dotfiles between `dotfiles/` and `~/.dotfiles`.
- `task brew:bundle` / `task brew:dump` – install or refresh the Brewfile.
- `task ides:windsurf` – sync the checked-in Windsurf settings to the live profile.
- `task ides:iterm2` – install the tracked `iterm2/com.googlecode.iterm2.plist` into `~/Library/Preferences/`.

Idempotence is enforced within each task, so re-running `task init` is safe at any time.

### Maintaining assets

- **Dotfiles** – edit files inside the top-level `dotfiles/` directory (aliases/functions/globals). Run `task dotfiles:sync` when you’re ready to apply them to `~/.dotfiles`, or `task dotfiles:pull` to bring live edits back into the repo.
- **Templates** – zshrc/git/ssh templates live under `templates/`. These are rendered via `envsubst`, so prefer `${VAR}` placeholders fed by `.env`.
- **Windsurf** – copy your current editor config from `~/Library/Application Support/Windsurf/User/` plus Codeium chat memories (e.g. `/Users/<you>/.codeium/windsurf/memories/global_rules.md`) into the repo’s top-level `windsurf/` directory. `task ides:windsurf` will mirror this folder into the live Windsurf profile.
- **iTerm2** – export your preferences to `iterm2/com.googlecode.iterm2.plist` (from `~/Library/Preferences/` or iTerm2’s export feature). Run `task ides:iterm2` to install the tracked plist onto the machine.

Keeping these directories as the source of truth ensures Taskfile changes remain predictable and reviewable.

## Apps under consideration:

- Wally
- Flux
- Krisp
- AWS VPN
- Intellij
- Gather
- Postman
