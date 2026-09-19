# Sajidhgn — Claude Code plugins

A private plugin marketplace for Claude Code (CLI and VS Code).

| Plugin | What it does |
|---|---|
| [`fullstack-ai-dev`](plugins/fullstack-ai-dev) | Senior full-stack AI developer: client intake with approval, stack detection, role-based implementation, client-perspective smoke testing, fix loop, delivery notes. See its [README](plugins/fullstack-ai-dev/README.md) and [CHANGELOG](plugins/fullstack-ai-dev/CHANGELOG.md). |

## Install

This repo is private, so Claude Code clones it with your own git access. Make sure `git clone` works for it on your machine first (for example after `gh auth login`, or with an SSH key).

**VS Code:** type `/plugins` in the Claude panel → **Marketplaces** tab → add `sajidhgn/claude-plugins` → **Plugins** tab → install `fullstack-ai-dev` (choose "Install for you").

**CLI:**
```text
/plugin marketplace add sajidhgn/claude-plugins
/plugin install fullstack-ai-dev@raw-studio
```

If you installed the plugin earlier by unzipping it into `~/.claude/skills/fullstack-ai-dev`, delete that folder after installing from here, so only one copy loads.

## Update

```text
/plugin marketplace update raw-studio
```
Then reload (`/reload-plugins`, or **Developer: Reload Window** in VS Code). Claude Code detects updates by the version in `plugin.json`, so every change needs a version bump.

## Maintenance workflow

1. **Log it immediately** — open an issue with the *Plugin issue* template while it's fresh: what you asked, what it did, what you expected.
2. **Reproduce it as an eval case** in `plugins/<plugin>/evals/<case>/` before fixing, so the fix is proven and can't silently come back.
3. **Change one thing**, then run only that case:
   ```bash
   cd plugins/fullstack-ai-dev
   claude plugin eval . --case <case> --runs 1 --ablation none --scaffold --allow-tools Write Edit "Bash(node *)"
   ```
4. **Run the free checks** (no model calls): `bash plugins/fullstack-ai-dev/tests/run-free-tests.sh`
5. **Bump the version** in `plugins/<plugin>/.claude-plugin/plugin.json`, add a line to its `CHANGELOG.md`, commit, push. CI re-runs the free checks on every push.
6. **Watch the size:** `claude plugin details fullstack-ai-dev` — if always-on tokens creep up, you're adding rules instead of fixing root causes.

**Fixed check-up triggers:** every 5 real runs · whenever a new Claude model ships (run the full eval) · any time a client is surprised by a delivery.

## Rollback

Every change is a commit. To go back, revert the commit (`git revert <sha>`), bump the version, push, then update the marketplace in Claude Code.
