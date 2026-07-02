# herdr Removal Path

Follow these steps in order to fully remove herdr from the machine and the repo.

1. Remove `brew "herdr"` from `Brewfile`; run `brew uninstall herdr`

2. Remove `HERDR_SRC` and `HERDR_DEST` vars from the `vars:` block in `Taskfile.yml`

3. Remove the `tools:herdr` task from `Taskfile.yml`

4. Remove `- task: tools:herdr` from the `init` task in `Taskfile.yml`

5. Remove `claude/herdr/` directory from the repo:
   ```
   git rm -r claude/herdr/
   ```

6. Remove the herdr row from the managed-destinations table in `CLAUDE.md`; remove the guardrail note below the table

7. Remove `~/.config/herdr/` from the machine:
   ```
   rm -rf ~/.config/herdr/
   ```

8. Verify: run `DRY_RUN=true task init` and confirm no herdr entries appear in the output

Commit the repo changes and push. No residual state should remain after step 7.
