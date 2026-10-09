---
name: jev-curation
description: Curate and expand the awesome-jev repository. Use when adding Jev projects or cases, collecting discussion evidence from X/Reddit/HN/blogs, promoting discussion items into main categories, refreshing README counts, or running periodic evidence sweeps.
---

# Jev Curation

Use this skill to maintain `awesome-jev` as a **strict, high-signal list of projects and practices built on Jev**.

## Goal

Keep the repository focused on two questions:

1. Where is Jev actually being used in public?
2. Which decision patterns transfer across domains?

This skill is for **curation**, not general AI news collection. Jev is a typed-decision model: `Choice`, `Score`, `Boolean`, each with confidence. Entries that do not involve a Jev decision do not belong here.

## Source of truth

Read these files before making changes:

- `README.md`
- `CONTRIBUTING.md`
- `tags.json`
- every file under `categories/`

`README.md` is the homepage aggregate, not the primary editing surface.
Update category files first, then refresh `README.md` from the current category files.
Always use `scripts/build-readme.py` instead of hand-editing the aggregate.
`tags.json` holds the entry tag vocabulary; the table in `CONTRIBUTING.md` is
generated from it, so add a tag value there rather than to either document.
An `agent` value also needs an evidence rule in `SUPPORT` in
`scripts/audit-tags.py`: without one, entries carrying it are never checked
against their own text. The audit names any value it has no rule for, so add
both in the same change.

## Hard inclusion rules

Only include items that satisfy at least one of these:

- explicitly name `Jev` / `jev`
- explicitly cite TypeSafe AI's System One models
- clearly implement a typed-decision loop (typed question → typed answer + confidence → accept / reject / escalate)

And all of these:

- source is public and citable
- description is concrete
- entry stays **one sentence**
- item is **strictly Jev-relevant**, not a generic classifier, router, or LLM judge

Reject:

- generic classifiers, routers, or decision agents with no Jev involvement
- launch-hype commentary with no artifact
- private or uncitable claims
- things that need a paragraph to justify inclusion

## Category model

Use **main category pages** for stronger evidence such as:

- public repos
- project pages
- substantial write-ups
- benchmark or evaluation results

Use **`categories/related-practices-discussions.md`** for:

- X threads
- Reddit discussions
- Hacker News threads
- interviews
- blog mentions

when they show credible real practice signals but do not yet have a strong standalone repo or case page.

The category list, their order on the homepage, and which files are still being
seeded all live in `CATEGORIES` and `OPEN_TRACKING` in `scripts/build-readme.py` —
read them there rather than from a copy that goes stale.

## Working strategy

### 1. Search broadly, classify narrowly

Preferred evidence channels:

- GitHub
- X / Twitter
- Reddit
- Hacker News
- Vercel AI Gateway / AI SDK ecosystem
- independent blogs / write-ups

### 2. Keep queries simple

Prefer medium-complexity searches such as:

- `jev typesafe`
- `typesafe-ai/jev`
- `jev Choice Score Boolean`
- `Jev System One Model`
- `jev classification routing`
- `jev verification guardrail`
- `Jev Diogo Almeida`

Avoid very long advanced-search expressions when the adapter is unstable.

### 3. Industrial and physical-world channels

The physical side of the ecosystem is invisible to every name search above: `jev ros2`,
`jev embedded`, `jev plc` and `jev industrial` all return zero repositories, and the
first entries in `robotics-physical.md` came from a web search instead. Search the
sources that cover that industry, not the model name:

- `gh search code 'api.typesafe.ai'` inside robotics and embedded repositories, or read
  their tree directly — a factory integration rarely says "Jev" in its description.
- ROS/ROS2 and embedded ecosystems: `gh search repos "ros2 decision model"`,
  `gh search repos "plc ai classifier"`, `gh search repos "edge inference classifier"`.
- Non-English industry writing. The 2–14 Hz decision-band framing — servo control around
  1000 Hz, VLA models 5–50 Hz, task planning under 1 Hz — came from a Japanese robotics
  column, not from GitHub.
- **Search by endpoint, not by name.** `api.typesafe.ai` and `/v1/systemone` appear in
  code long before anyone writes the word Jev in a description. Two collisions make name
  search unreliable here: **System One is also an unrelated company** (systemone.com,
  flooring and defect software), and MES, SCADA and PLC are generic acronyms that return
  other people's products in prose search.
- **Expect the deployments to be private, and say so.** Factories rarely publish their
  in-house classifier. What stays citable is the enabling layer (OPC-UA, Modbus, BACnet
  and IEC 61131-3 tooling, bounded-action runtimes), vendor case studies and conference
  talks. Absence of a public deployment is not evidence of absence of use — record what
  is public and label it as such rather than concluding the field is empty.

### 4. Chinese + English

Search in both languages when useful. Useful Chinese patterns:

- `jev 大模型 决策`
- `TypeSafe Jev 分类`
- `Jev 类型化决策`

Keep Chinese queries narrow to avoid noisy generic matches.

## `last30days`: the multi-channel sweep

`last30days` (mvanhorn, MIT) is installed at `~/.agents/skills/last30days`, a symlink into the vendored clone at `~/.agent-reach/vendor/last30days-skill/skills/last30days`. It resolves for every project, so this repo and its sibling list share one copy; update it with `git -C ~/.agent-reach/vendor/last30days-skill pull`.

```bash
SKILL=~/.agent-reach/vendor/last30days-skill/skills/last30days
python3 "$SKILL/scripts/last30days.py" doctor          # which sources are alive, and how to fix the dead ones
python3 "$SKILL/scripts/last30days.py" "TypeSafe Jev" --days 7 --emit json --output /tmp/sweep.json
```

Then read `/tmp/sweep.json` and pull `url` / `title` per source. Live out of the box on this machine: reddit, youtube (via yt-dlp), hackernews, polymarket, github (via `gh`). X is unconfigured until `setup --allow-browser-cookies` runs, so keep using `twitter search` for X in the meantime.

**What it reaches that the manual sweep cannot.** Two classes show up here and nowhere else:

- **Unmerged integrations.** A pull request or an issue that adds Jev to an existing project is invisible to `gh search repos` and `gh search code`, because the code is not on the default branch and the repository never matches. `open-orcha/orcha#253`, `wso2/api-platform#3517`, `ahstn/oceans-llm#387` and `fakoli/anvil#238` all arrived this way — five third-party projects integrating Jev that the name-based searches had missed across a dozen prior passes.
- **Discussion in places nothing indexes.** Small-subreddit threads, conference talks, personal blogs. The sharpest critique of the calibration claim came from r/ArtificialInteligence, and the design rationale from a Diogo Almeida talk — neither was reachable from a repository search.

Treat it as a complement, not a replacement: it is strong on recency and breadth, while `gh search` remains better for exhaustive repository coverage. Run both, and reconcile.

## Promotion workflow

Use this exact ladder:

1. **Discussion lead found**
   - Add to `categories/related-practices-discussions.md` if it is credible and directly Jev-related.
2. **Evidence chain search**
   - Look for repo, project page, case page, or blog post.
3. **Promotion test**
   - Promote only if public evidence clearly shows a real Jev decision in use.
4. **Promote**
   - Move it into the best-fit main category.
5. **Deduplicate**
   - Remove the weaker discussion-only item if the main case now covers it.
6. **Refresh counts**
   - Run `scripts/build-readme.py` if category totals changed.

## Entry-writing rules

### Main categories

Format:

```md
- [Name](URL) - Industry: one-sentence description of the Jev use case.
```

Rules:

- one sentence only
- must mention the decision + the typed shape (`Choice` / `Score` / `Boolean`) + the gate or escalation
- prefer concrete verbs like `classifies`, `routes`, `gates`, `scores`, `verifies`
- include a number when the source provides one
- avoid hype

### Discussions page

Format:

```md
- [Name or thread title](URL) - Source/platform: one-sentence description of the Jev-related practice or discussion.
```

Rules:

- keep it factual
- describe the practice signal, not your opinion
- if it is mostly about transfer of the pattern, say that clearly

## Periodic maintenance loop

When invoked for a recurring sweep:

1. Read the current category files.
2. Search for 3-10 new public leads.
3. Filter aggressively.
4. Add only high-signal entries.
5. Attempt promotion for the strongest discussion leads.
6. Remove duplicates.
7. Recount category totals.
8. Refresh `README.md` so the homepage aggregate matches the current category files and counts.
9. Publish one short X post covering the round, following the 统一格式 in `/skill:tweet-posting-cdp` (same layout for both awesome lists), then summarize what was added, promoted, and rejected.
   - Verify with `DRY_RUN=1` first; the script prints `内容校验通过：N 字符 / M 段落` and must match before actually posting.

## Suggested commands

Count entries:

```bash
python3 scripts/build-readme.py && sed -n '/## Current coverage/,/Each entry lives/p' README.md
```

Example searches:

```bash
bb-browser site twitter/search 'jev typesafe' --json
bb-browser site google/search 'site:github.com "typesafe-ai/jev" OR "jev" typesafe | sed -n "1,120p"'
bb-browser site google/search 'site:news.ycombinator.com jev typesafe | sed -n "1,120p"'
bb-browser site google/search 'site:reddit.com jev typesafe model | sed -n "1,120p"'
opencli gh api repos/typesafe-ai/jev/readme
```

## Quality bar

**Promote slowly. Add discussions faster.**

If evidence is good but not strong enough for a main case, keep it in discussions.
Precision beats coverage. This model shipped in September 2026, so the corpus is small — resist padding it.

Before adding a repository, check depth (see CONTRIBUTING.md, "AI-assisted work, and bulk submissions"):

- Does the code actually call the Jev API, or is the claim README-only?
- Is there a runnable check (test, example with expected output, public demo)?
- Is the repository mostly prompt documents? Then describe it as such, or skip it.
- Does a batch of same-day repositories share one scaffold? That is a risk signal, not momentum — review each on its own merits, and take at most three entries per author in a single pass, queuing the rest.
- Are the numbers in the entry traceable to the linked page? Strip what you cannot verify.

## Handling pull requests

When a contributor opens a PR:

1. Verify the repository, do not just read the PR body — file tree, source, tests, CI, commit history, and whether the code really calls the Jev API.
2. If the repository is thinner than the entry implies (README-only claims, no runnable check, docs outweighing code), say so in a review comment and ask for the missing evidence rather than merging or silently rejecting it.
3. When an author already has three entries accepted in the current pass, state the rule in the PR comment *before* acting, and queue the extra entries to a later pass instead of rejecting them. Queued entries count against the pass that takes them, not the one that queued them, so honour the queue even when it lands the author a fourth or fifth entry inside the same week. Link the CONTRIBUTING section so the contributor knows it is policy, not a judgement about them. Queue by submission order, never by quality — picking "the best three" turns the rule into a hidden quality verdict, which is exactly what it exists to avoid. If one of the queued entries has more stars than the merged ones, say so explicitly in the comment.
Keep a PR reply short: the rule in one line, what happens next in one line, then stop. No restating the contributor's work, no explaining the queue's arithmetic, no advice they did not ask for. 4. **Bulk AI-generated submissions are a rule, not a preference** (CONTRIBUTING → "Rule: do not submit bulk drops of AI-generated projects"). Before merging a cluster of same-author, same-day repositories, check for a shared scaffold (`AGENTS.md` / `CLAUDE.md` / `STATE.md`), a common README template, or single-commit histories — those mark one project family, which counts as **one** submission, so merge at most one and queue the rest. Disclose-or-pause also applies: if a submission was generated and not disclosed, hold the author's whole pending batch until they say so.
5. Never edit a contributor's wording purely for style; do fix inaccurate claims.
6. README.md is generated — when a PR conflicts there, rebase the branch and regenerate it (`python3 scripts/build-readme.py`) rather than hand-resolving. For conflicts in a category file, keep main's version and append the PR's new line.
7. An entry written **only** into `README.md` (no category file) will be silently erased by the next generator run — the merge is clean, CI is green, the count is unchanged, and the entry is gone. Do **not** close the PR and apply it to main by hand: that shows the contributor a closed-unmerged PR and puts their contribution on your commits. Put the line into the right category **on the PR branch** and merge the PR:
   ```bash
   RELOCATE_INTO=infra-sdks-integrations.md scripts/maintainer/merge-prs.sh <PR>
   ```
   The script relocates the line, normalises the separator (`ENTRY_RE` accepts only ` - `, but hand-written README lines use `:` or an em dash), regenerates the README, commits on the branch and pushes it back. It refuses to merge without `RELOCATE_INTO`, because choosing a category is an editorial call, not a guess. When the contributor has not enabled maintainerCanModify the push fails, and the script falls back to a **local** merge whose message is exactly `Merge pull request #N from fork/branch` — GitHub associates that commit with the PR, so the PR still reads as merged and the contributor's commit is really in main. Verify afterwards with `python3 scripts/build-readme.py && git diff --quiet`: no drift means the entry came from the category file and not from README.
   Do this even when the PR's own wording leads with a competitor's model: `Bud-Decision-Studio` led with Laya and Kev, but the repo calls itself "the LM Studio of Jev-like System One models" and runs Jev-Omni, so it was on topic and worth the extra step.
8. Use `scripts/maintainer/merge-prs.sh` to process PRs in bulk. It handles the four traps that make manual merging tedious: fork repository names vary (`awesome-jev`, `awesome-jev-yibie`, `yibie_awesome-jev`, `awesome-jev-1`), so it resolves them via `headRepository.nameWithOwner`; it fast-forwards local `main` before rebasing, because rebasing onto a stale base leaves the PR conflicting after the push; it loops over conflict rounds, because a PR with two commits (add the entry, then reword it) conflicts twice; and it appends the PR's entry with `grep -qF --` so an entry starting with `- [` is not parsed as a grep option.
9. A PR that edits only a category file merges cleanly and leaves the README count stale, so `merge-prs.sh` rebuilds the README after every merge and pushes a follow-up commit when it drifted.
10. Every PR touches the adjacent count lines in README.md, so from the second PR onward conflicts are normal, not a sign of a bad contribution. Expect to rebase and force-push to the contributor's branch (most forks have `maintainerCanModify: true`) rather than asking them to resolve it.

## Deliverable checklist

Before finishing, verify:

- entries are one sentence
- no generic classifiers or judges slipped in
- promoted items have stronger evidence than discussion-only items
- discussions page remains useful as a map of emerging practice
- README homepage aggregate matches the current category files

## Recommended invocation phrases

This skill should be used for prompts like:

- "继续搜集 awesome-jev"
- "做一轮 Jev 证据巡检"
- "把 discussions 里强条目升格"
- "更新 jev awesome list"
- "定期维护这个仓库"
