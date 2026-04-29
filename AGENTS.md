# AGENTS.md

## Conventions for install steps

Each step is a function named `step_<name>` and must be registered in the `ALL_STEPS` array and the usage text.

Steps follow a consistent pattern:
1. Check if already configured → skip (unless `--force`)
2. Perform the action via `run_cmd` / `run_sudo_cmd` (never raw commands — these handle `--dry-run`)
3. Print `success` on completion

When adding/updating steps:
- Keep `ALL_STEPS`, usage text, and `README.md` steps table in sync
- Maintain the same order across all three
- Remove old key files before regenerating (e.g. `rm -f` before `ssh-keygen`) to avoid interactive prompts
- Suppress noisy command output with `>/dev/null 2>&1` inside the `run_cmd` string

## Running
**NEVER run the script outside of dry-run, if you need the user to test ask them to do it manually.**