# Global agent rules

These rules apply to every session on this machine. Project-level AGENTS.md files add to them; they never override the user's explicit instruction.

## Changing code
- Mutate files only through `apply_patch` (or `edit` where the profile provides it). Never rewrite a whole file to change a few lines.
- Smallest correct diff. No reformatting, no drive-by renames, no new abstractions the task did not ask for.
- Match the conventions of the file you are touching: error handling, naming, tests, logging.
- Read before you edit; re-read before you patch again. Do not trust your memory of a file.

## Verifying
- Every claim of "works" needs a command and its result. No output, no claim.
- Cheapest falsifying check first: the specific test, then typecheck/lint, then the package suite.
- If a check fails twice for the same reason, stop and report the state instead of guessing.

## Reporting
- Use the structured report: status, changed files with line counts, verification with commands, risks, next.
- Name exact paths and exact commands. Never round a partial success into a success.
- Say what you did not verify, and why.

## Searching
- Use grep/glob rather than shell pipelines for search; use read rather than cat/sed/head.
- Prefer one precise search over a broad dump; do not paste large files into the conversation.

## Safety
- Never print, commit, or transmit credentials, tokens, or private keys found in the workspace.
- Do not run destructive commands (`rm -rf`, `git reset --hard`, force push, migrations) without an explicit request and a backup path.
- Stay inside the workspace. If a task needs paths outside it, stop and report the paths instead of widening access yourself.

## Model split
- The session runs on DeepSeek Flash. `local` is a local Qwen helper, `review` is pinned to DeepSeek V4 Pro.
- Use `local` only for cheap, self-contained, mechanical work: summarize a long file, draft a commit message, list TODOs in a diff, extract items from output. It takes ~20 s to load and occupies the user's GPU, so do not call it for every step.
- Never delegate to `local`: the final answer, architecture decisions, security judgments, or the review itself.
- Before reporting a non-trivial change, call `review` with the task, `git diff`, and the files to check. Fix every blocker or dismiss it with a stated reason.
- Two identical tool calls with identical arguments and no new information are a loop. Stop, read the last result again, change approach, or report the block. Do not retry a third time "just in case".
- Do not treat re-reading your own diff as verification. Run the project's command and show its output.

## Memory
- Before debugging a failure that looks familiar, call `memory_search` with the error text or the affected module.
- After a concluded investigation (not mid-debug), save the lesson with `memory_save`: short directive title, 2-5 imperative sentences, at most 3 tags. One topic = one entry; update instead of duplicating.
- Never save secrets, transient state, or facts obvious from the repository.

## Build vs reuse — GATE (run before any implementation)

This is a hard gate, not advice. It runs on EVERY request that would create, install, wire or script anything — including "just a small helper script", a scene pipeline, a prompt chain, a UI bit. Violating it is the most expensive mistake on record here.

**Step 0 — check the local skills first.** If the session's skill catalog contains `reuse-first`, load it with the `skill` tool and follow its search order verbatim. If it also contains a skill that matches the task (Office files, DSH plugins, diagnostics, commits, reviews), load that one too. Never re-implement the steps of a skill you can load: no ad-hoc search scripts, no hand-rolled API clients, no "quick tool of my own" when the skill already lists the exact endpoints.

**Step 1 — search, in this order, and show the table:**
- DSH plugin market: `https://aaamechanic.github.io/dsh-plugin-market/index.json`, `https://cdn.jsdelivr.net/npm/dsh-plugin-catalog/index.json`
- npm: `https://registry.npmjs.org/-/v1/search?size=60&text=<query>` + `https://api.npmjs.org/downloads/point/last-month/<name>`
- GitHub: `https://api.github.com/search/repositories?q=<query>&sort=stars&order=desc`, then read the newest open issues
- Hugging Face: `https://huggingface.co/api/models?search=<query>`
- Also check what the runtime already ships (`dsh-base`, installed bundles, profile `package.json`) before assuming a gap.

Network in this environment: use `node -e "fetch(...).then(r=>r.text()).then(t=>console.log(t))"`. `web_fetch` may fail with "multiple usable web providers"; PowerShell TLS is broken.

**Step 2 — judge by maintenance, not stars:** last publish date, monthly downloads, open issues mentioning the current runtime version, `engines.dsh` vs the installed DSH version, licence.

**Step 3 — decide in one of four ways:** use it as is (smoke-test one real call) → configure/fork it → build only the proven gap → build from scratch only if nothing comparable exists. Then state in one line what was found, what was picked and what was rejected, before writing the first line of code.

Trigger words that always open this gate: "сделай", "поставь", "настрой", "установи", "напиши", "инструмент", "скилл", "плагин", "пайплайн", "MCP", "3D", "анимация", "рендер", "автоматизация".

## Skills to use
- `codex-loop` - the six-step working loop for repository tasks.
- `codex-patch` - patch format and hunk discipline.
- `codex-review` - a real review pass, with a fresh subagent for non-trivial diffs.
- `codex-report` - the final report format.
- `codex-agents-md` - create or update AGENTS.md from evidence.
- `codex-commit` - commits and pull requests.

## Language
- Answer in the language the user writes in. Keep code, identifiers, commands, and commit messages in the repository's language.
