---
name: reuse-first
description: Before inventing a component, search the DSH plugin market, npm, GitHub and Hugging Face, read issues and reviews, and pick the maintained option. Use at the start of any build-or-depend decision, including "small helper scripts", 3D/render pipelines, MCP servers and scene/animation workflows.
---

# Reuse first

> Железное правило: сначала загрузить этот скилл и выполнить его порядок поиска. Свои поисковые скрипты и «быстрые инструменты» не писать — здесь уже есть все нужные URL. Результат поиска показывать таблицей до первой строки кода.

Any "let's build X" where X is a plugin, skill, browser integration, memory layer, workflow, or UI feature. Five minutes of searching beats a day of building.

## Search order

1. **DSH plugin market** (about 2000 packages):
   - `https://aaamechanic.github.io/dsh-plugin-market/index.json`
   - `https://cdn.jsdelivr.net/npm/dsh-plugin-catalog/index.json`
   - `dsh plugin --profile <p> list` for what is already installed.
2. **npm registry search** (JSON, no auth):
   - `https://registry.npmjs.org/-/v1/search?size=60&text=<query>`
   - metadata: `https://registry.npmjs.org/<name>` (gives version, time, repository, `dsh` manifest, peers)
   - popularity: `https://api.npmjs.org/downloads/point/last-month/<name>`
3. **GitHub**: `https://api.github.com/search/repositories?q=<query>`; then read the repo's open issues and the last 10 commits. Stars alone mean nothing.
4. **Hugging Face** for models and quants: `https://huggingface.co/api/models?search=<query>`; for a repo, `https://huggingface.co/api/models/<repo>` lists GGUF files.

## Judge before choosing

- Last publish date and last commit; a package untouched for 6 months on a fast-moving harness is a risk.
- Monthly downloads as a rough proxy for "someone else ran it".
- Open issues: read titles of the newest 5-10. Breakage reports for the current runtime version are disqualifying.
- `dsh` manifest + peerDependencies: does it support the installed version? Version pins that exclude the current runtime mean no.
- License and size of the dependency tree.

## Decide

1. Use the existing package (install, smoke-test one real call, verify it appears in tools/UI).
2. Fork or configure the existing package if one setting is missing.
3. Build the minimal gap only, and reuse the package's protocol/conventions.
4. Build from scratch only when nothing comparable exists.

Report a small table: name, version, updated, downloads/month, verdict. Then one line: what was chosen and why. Do not hide a rejected candidate that looked promising — say why it lost.

## Anti-patterns

- Writing a client plugin or tool before checking the market.
- Choosing by stars or README alone, without reading recent issues.
- Installing without checking the runtime-version pin.
- Rebuilding something the harness already ships (check `dsh-base` and the shipped bundle first).
