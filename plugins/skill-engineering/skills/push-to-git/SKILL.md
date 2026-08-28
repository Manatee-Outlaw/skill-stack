---
name: push-to-git
description: >
  Commit all changes, push to GitHub, and auto-deploy to the production server in one step.
  Trigger immediately when the user says "push to git" — with or without a commit
  message. Also triggers on "deploy", "ship it", "push changes".
metadata:
  tier: machine
  plugin: skill-engineering
---

# Push to Git

Commits all staged and unstaged changes, pushes to GitHub, and pulls + restarts
the service on `<production-server>`. One command, full deploy cycle.

## Trigger
`push to git` / `push to git [message]` / `deploy` / `ship it` / `push changes`

---

## Execution — Run All Steps in Order

### Step 1 — Get the commit message

If the user included a message (e.g. "push to git fix discord bot"), use that as
the commit message.

If no message was provided, ask:
> "What's the commit message? (Or say 'default' for a timestamp.)"

If the user says "default" or similar, generate: `Deploy YYYY-MM-DD HH:MM` using
today's date.

---

### Step 1.5 — Skill registration gate (run before creating task.md)

If this commit adds or renames ANY file under a skill directory
a new skill was added, the push is NOT complete until `scripts/validate.py`
passes.

Check it mechanically, do not eyeball it:

```bash
python3 scripts/validate.py
```

It must print `PASS`. It enforces structure (SKILL.md present and correctly
capitalised, name matching its folder, no duplicates), the account-store limits
(name <=64, description <=1024 - a universal-tier skill over the cap silently
fails to upload), and the portability gate (no project names, no absolute paths,
no undeclared cloud coupling, no raw GitHub self-links).

Any error means stop and fix it before pushing.

Why this gate exists: on 2026-07-24 `adhd` was committed and pushed correctly,
but no bundle referenced it, so no session ever loaded it. It was then missed on
a brainstorm request - the exact use case it was written for. Writing the file is
half the job; publishing it is the other half.

**The failure changed shape but did not go away.** Bundles are retired, so a
skill can no longer fall off a load list. It can still be unreachable - by having
a description too vague to match how anyone actually speaks. That failure is
identical from the outside: a skill that never fires looks the same as one that
loaded and was not relevant. `validate.py` catches the structural half;
`skill-library-audit` Check 1 catches the reachability half. Neither is optional.

---

### Step 1.6 — Diff-intent gate (run before every commit, not just skill commits)

**The commit message states an intent. Prove the staged diff matches it before committing.**

```bash
git status --short
git diff --cached --stat
```

Read the shape, not the filenames. A commit message that says something was **removed**
must show deletions and few or no insertions. One that says a file was **added** must show
a new file mode. If the message and the stat disagree, **stop** — the working tree is not
in the state the message describes, and committing will publish something nobody reviewed.

Do not proceed on the assumption that a preceding cleanup command succeeded. Verify the
tree, because a command that failed and a command that succeeded leave identical-looking
prompts.

Why this gate exists: a folder was to be deleted from a public repository because its
contents had been reclassified as private. The delete command was issued in the wrong
shell dialect, errored, and left the folder in place. `git add -A` then staged an
unrelated pending edit, and the commit was made with the message *"move to the private
set"*. The stat read `2 files changed, 155 insertions(+), 56 deletions(-)` — insertions,
for a commit that claimed to remove something. Nobody read it. The push published the
private content to a public repository, and the commit message actively concealed that,
because it described the intended outcome rather than the actual change.

The stat line was correct, visible, and free. It was simply never compared against the
sentence sitting directly above it.

---

### Step 2 — Create task.md

Use bash_tool to create `/mnt/user-data/outputs/task.md` with the following content,
substituting [MESSAGE] with the commit message from Step 1:

```
Run these four commands in order. Show the full output of each before moving to the
next. Stop and report if any command fails.

1. git add -u
2. git commit -m "[MESSAGE]"
3. git push
4. ssh <user>@<production-server> "cd <project-dir> && git pull origin main && sudo systemctl restart <service> && echo 'Deploy complete'"
```

Note: use `git add -u` (updates tracked files only) not `git add .` (adds all untracked
files). If there are intentional new files to include, add them explicitly with
`git add <filename>` before running this task.

---

### Step 3 — Present the file

Present task.md for download. Tell the user:

> "Save this to `<projects-dir>\<your-repo>\task.md`, then in Claude Code type:
> `read task.md and execute all commands`"

---

### Step 4 — Confirm

After the user pastes the Claude Code output back here:

- If all four commands succeeded and "Deploy complete" appears → confirm the deploy is live
- If git commit shows "nothing to commit" → tell the user there were no changes to push
- If git push fails with auth error → SSH key needs re-adding to GitHub
  (Settings → SSH keys → New → Authentication Key → paste `cat $HOME\.ssh\id_ed25519.pub`)
- If SSH to `<production-server>` fails → check it is reachable: ping <production-server>
- If systemctl restart fails → check gunicorn_error.log on `<production-server>` for Python syntax errors

---

## Hard Rules

- Never skip Step 4 — always confirm `<production-server>` pulled successfully, not just that the push succeeded
- If the user says the `<production-server>` SSH step failed but push succeeded, the code is on GitHub
  but NOT live — flag this clearly
- Always use the exact SSH command above — do not abbreviate or skip the restart
- Never use `git add .` blindly — use `git add -u` for modified tracked files
- Never report a skill as "pushed", "added", or "live" on the strength of the commit alone — a skill is live only once a bundle names it. Run the Step 1.5 orphan check and quote its (empty) output before saying so.
