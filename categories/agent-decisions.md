# Agent Decisions

Use this category for programs where Jev supplies the decision step inside an agentic loop — tool choice, escalation, retry or stop, next-action selection.

## Submission format

```md
- [Name](URL) - Industry: one-sentence description of the Jev use case.
```

## Entries

- [jev-social](https://github.com/socai-io/jev-social) - Social media research: uses a Jev `Choice` at each step to select a concrete socai CLI operation and observed post or profile target on Instagram, TikTok, or LinkedIn, rejecting malformed or low-confidence decisions before execution.

- [Jev Ultrafast](https://github.com/browser-use/jev-ultrafast) - Browser automation: browser-use's ultrafast agent where Jev decides each next action and element to click, calling a language model only when text must be typed.
- [jev-agent-browser](https://github.com/forvela/jev-agent-browser) - Browser agents: a parent agent delegates bounded tasks to a Jev loop that selects typed browser actions, validates them through agent-browser, and escalates ambiguity or stuck states back to the parent.
- [pi-typesafe-jev](https://github.com/legacybridge-tech/pi-typesafe-jev) - Coding agents: exposes System One judgments as five Pi tools so a model makes narrow semantic judgments while code and users keep control of thresholds, weights, and actions.
- [jev-judgment](https://github.com/HyunjunJeon/jev-judgment) - Coding agents: agent skill that sends closed coding-agent judgments to Jev so verdicts stay typed, cheap, and comparable across runs.
- [limpet](https://github.com/noplan-inc/limpet) - Coding agents: Stop hook that keeps an agent from finishing too early by judging plain-language completion rules with Jev.
- [robo-harness](https://github.com/grmkris/robo-harness) - Robotics: SO-101 arm workbench where a Jev decision runner picks bounded joint steps from typed candidate actions under a spend budget.
- [dsh-auto-mode](https://git.allen-software.com/allenh1/dsh-auto-mode) - Coding agents: DeepSeek Harness permission preset whose end-prompt step has Jev answer the open questions an agent leaves in its final message, steering them back only when a choice clears 0.6 confidence and an autonomy-safety Noul clears 0.5, and returning the turn to the human otherwise.
- [augustus](https://github.com/24601/Augustus) - Coding agents: agent skill that maps Choice, Score, and Noul onto classical methods so an agent can place typed judgment in software, with a composition algebra, question-design diagnosis, and a validation gate that requires a falsifying experiment.
- [yoshi](https://github.com/compozy/yoshi) - Context management: proxy for Claude Code and Codex where Jev judges which conversation history is still needed before pruning.
- [pi-jev (TheoOliveira)](https://github.com/TheoOliveira/pi-jev) - Coding agents: semantic tool routing and typed System One decisions for the Pi coding agent.
- [pi-quiet-ask](https://github.com/HyunjunJeon/pi-quiet-ask) - Coding agents: gives the Pi agent a quiet Jev decision layer for judgments it would otherwise hand to a chat model.
- [fastbrowse](https://github.com/agent-labs-dev/fastbrowse) - Browser agents: Jev picks each action from what is on the page while an LLM reads and plans.
- [super-jev](https://github.com/Kevthetech143/super-jev) - Decision harness: turns a Jev answer into a bounded action instead of leaving the caller to interpret it.
- [jev-superpowers](https://github.com/AkashPriyadarshii/jev-superpowers) - Systematic software development framework for AI coding agents upgraded with TypeSafe Jev System One typed decisions, zero-hallucination package vetting, and completion gates.
- [Jev Browser](https://github.com/jkudish/jev-browser) - Browser automation: drives a browser with Jev deciding each step, pitched as fast and very cheap next to LLM-driven browsing.
- [pi-fast-jev-compaction](https://github.com/joelhooks/pi-fast-jev-compaction) - Context management: Pi extension that keeps conversation text verbatim while pruning stale tool history with Jev, falling back to Pi's own summarization only when pruning cannot free enough room.
- [Atomic](https://github.com/bastani-inc/atomic) - Coding agent runtime: ships a first-class Jev structured-output provider so an agent's decisions come back typed, through the same decision resolver as its other providers.
- [fast-jev-compaction](https://github.com/tamaratran/fast-jev-compaction) - Context management: Claude Code plugin that replaces the compaction summary with Jev decisions, scoring every tool call and result for whether it is still needed instead of summarizing the session.
- [fast-dev-compaction](https://github.com/leonaaardob/fast-dev-compaction) - Context management: Codex port of the Jev-guided compaction idea, restoring context verbatim around a session compaction rather than summarizing it.
- [public-browser](https://github.com/Silbercue/public-browser) - Browser control: lets Claude Code and Cursor drive a real Chrome profile, with a Jev loop deciding the actions, reporting roughly 30% fewer tokens and 25% lower cost.
- [pi-typesafe-router](https://github.com/jekozyra/pi-typesafe-router) - Coding agents: routes Pi's work through typed Jev decisions.
- [wakegate](https://github.com/shitianfang/wakegate) - Long-running agents: before a sleeping agent's LLM is resumed on a timer or incoming event, Jev answers a `Choice` (wake, not yet, unrelated) against the agent's own sleep note, and code skips the wakeup only when wake is below 0.2 while always waking on user messages, bare timers, a skip limit, errors, and timeouts; one run passed 21 of 21 hand-written scenarios, which the README calls a smoke test rather than a benchmark.
- [BrowserClaw](https://github.com/GoldenLoaf24h/browserclaw) - Browser automation: Zero-lock, session-preserving Chrome MCP server that couples a local Jev System One semantic micro-loop (`chrome_act_toward_goal`) with an 85%+ pruned DOM tree (Shadow DOM & iframe pierced), dispatching native CDP events (`isTrusted: true`) on active logged-in sessions without focus theft.
- [jev-canvas](https://github.com/gaborishka/jev-canvas) - Multimodal UI: draw on a tldraw canvas by voice while pointing a webcam-tracked finger; on every partial transcript Jev answers eight typed questions (is it a command, is the sentence complete, action, shape, colour, target, place, size) and plain code gates them with thresholds, in English and Ukrainian, 300–550 ms per decision.
- [jev-belay](https://github.com/valentynkit/jev-belay) - Coding agents: Claude Code Stop hook that reads the transcript for evidence and spends one four-question Jev call only when files changed with no passing check since, failing open on any error.
- [Jev for Chrome](https://github.com/chy4pro/jev-for-chrome) - Browser automation: unofficial Chrome extension port of Jev Ultrafast where a Jev `Choice` picks the operation and DOM element each step and two `Noul` checks (goal reached, stuck) veto a premature DONE or BLOCKED, with a small text model used only when text must be typed.
- [jev-pruner](https://github.com/tamaratran/jev-pruner) - Context management: Claude Code plugin that trims long Bash output with Jev before the model ever sees it, keeping terminal noise out of the window.
- [jev-desktop](https://github.com/yikangy873-gif/jev-desktop) - Computer use: supplies Jev action selection inside Codex Computer Use, choosing among desktop actions rather than asking a language model at every step.
- [jev-agent-skill](https://github.com/yuyang2230/jev-agent-skill) - Developer tooling: Claude Code/ZCode skill that offloads classify/route, batch-screen, score, and compliance-check judgments to Jev via OpenCode Zen's free tier, bundling a zero-dependency jev.py caller (transient-500 retry, WAF-safe UA, GBK-pipe-safe stdin) and a production Taobao-shop comment-triage pipeline that keeps raw items out of the agent context.
