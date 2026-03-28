---
name: nvim-log
description: Log neovim config changes to the decision log. Use this when the user asks to log, record, or document neovim/nvim changes made in this session or recently in the repo.
disable-model-invocation: true
---

Log neovim config changes to the decision log at $OBSIDIAN_VAULT/10-projects/dotfiles/nvim/config-nvim-decision-log.md.

Steps:
1. Read the decision log file to see the current content and latest date heading.
2. Gather changes to summarise from two sources:
   a. Changes made in this conversation (if any).
   b. Recent git commits in the nvim config repo (`git log --oneline -20` and `git show` for relevant commits) that are not already covered by existing log entries.
3. Summarise all changes — focus on *what* was changed and *why*, not implementation details. Follow the style of existing entries: short bullet points grouped under bold headings per change area.
4. If today's date already has a `## YYYY-MM-DD` section, append under it. Otherwise create a new one.
5. Update the `updated:` frontmatter field to the current date and time. Run `date +"%Y-%m-%d %H:%M"` to get the exact value.
6. Keep entries concise — one or two bullets per change is ideal.
