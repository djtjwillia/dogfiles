# Round 1 Questions – Ansible-to-Task Migration

Please answer directly in this file by replacing the placeholder text after each question. Multiple-choice prompts include an "Other" option if none fit.

1. **Primary runner preference** – Which automation runner best fits your desired workflow?
   1. ☐ Taskfile (go-task)
   2. ☐ Justfile (case-sensitive make-like syntax)
   3. ☐ Makefile (stay closer to POSIX make)
   4. ☐ Other (describe)
   > Answer: Taskfile

2. **Execution ergonomics** – How do you expect to trigger provisioning?
   1. ☐ Single top-level command (e.g., `task init`)
   2. ☐ Multiple targeted commands per subsystem (dotfiles, apps, etc.)
   3. ☐ Mix of orchestration + targeted commands
   4. ☐ Other (describe)
   > Answer: single top-level command

3. **Scope of retained functionality** – Which existing Ansible capabilities must carry over?
   1. ☐ Everything in playbook.yml (1:1 parity)
   2. ☐ Only dotfiles + Homebrew bootstrap
   3. ☐ Only config templating (zshrc, ssh, git)
   4. ☐ Other (describe)
   > Answer: I want to keep dotfiles, homebrew, zshrc, and convert the vscode setup to a setup for Windsurf (my settings, including my AI chat settings). For now I want to try to keep the git and ssh config, but i want to make it easy to rip it back out if i change my mind.

4. **Secret/identity handling** – How should sensitive values (SSH, git signing key) be provided?
   1. ☐ Prompt during run
   2. ☐ Environment variables / `.env`
   3. ☐ Local, untracked files (current approach)
   4. ☐ Other (describe)
   > Answer: lets go with an untracked .env file

5. **Target environments** – Besides your personal Mac, do you need the new system to support other hosts?
   1. ☐ Only my personal Intel/Apple Silicon Macs
   2. ☐ Multiple Macs with different personas (work/personal)
   3. ☐ Linux or container targets as well
   4. ☐ Other (describe)
   > Answer: i want it to target silicon macs, and we will treat work and personal as the same mac. so I want to be able to specify personal and work idientities

6. **Validation + idempotence expectations** – What level of safety checks should run?
   1. ☐ Basic "exists" checks before copying (current Ansible level)
   2. ☐ More detailed validation/logging per step
   3. ☐ Dry-run capability before applying changes
   4. ☐ Other (describe)
   > Answer: i want it to be idempotent, and i want it to be safe. i want it to be able to run multiple times without doing anything if it has already been run. I want to be able to dry run and have detailed validation and logging (if not too complex)

7. **Future extensibility goals** – What additions should the new system make easier?
   1. ☐ Adding/removing apps + dotfiles quickly
   2. ☐ Running per-machine overrides (e.g., work-only tasks)
   3. ☐ Integrating with CI/remote bootstrap
   4. ☐ Other (describe)
   > Answer: i want to be able to easily update my brewfile, and i want to be able to easily update my dotfiles. i want to be able to run per-machine overrides (e.g., work-only tasks)

Thanks!
