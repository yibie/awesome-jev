# Evaluation & Benchmarking

Use this category for programs where Jev judges model or system outputs — eval harnesses, LLM-as-judge replacements, benchmark scorers, regression gates.

## Submission format

```md
- [Name](URL) - Industry: one-sentence description of the Jev use case.
```

## Entries

- [Jev Web Analyzer](https://github.com/replynodes/jev-web-analyzer) - Product evaluation: analyzes a public SaaS landing page as clean Markdown and asks Jev ten bounded `Choice` questions about first-visit understanding, returning inspectable findings for the first change to make.

- [Jev Playground](https://github.com/hegargarcia/jev-playground) - Model evaluation: benchmarks Jev against Luna, Haiku, and Gemini at choosing validated legal moves in explicit-state games, scoring decision quality and consistency across a sequence of moves.
- [Jev vs Mistral and Gemini for event validation](https://nearhere.events/blog/typesafe-jev-mistral-gemini-event-validation) - Event discovery: head-to-head test of Jev against Mistral Small and Gemini Flash-Lite at validating local event listings.
- [jev-research-eval](https://github.com/jgridifier/jev-research-eval) - Research automation: reproducible eval harness plus field note for Jev Ultrafast research-browser tasks, with QC'd cases, a suite runner, and a report generator.
- [Jev judge call vs dimension scores](https://agentjournal.dev/blog/llm-judge-vs-feature-extraction/) - Model evaluation: tests one direct Jev question per row against 12–14 Jev-scored dimensions with locally fitted weights on three classification tasks, reaching 0.9076 against 0.8373 on Japanese NLI but flagging about 25× more hard benign rows as attacks.
- [Jev Pong](https://github.com/ably-labs/jev-pong) - Model comparison: Pong where the ball advances one step per model decision, putting Jev head-to-head with LLMs through Vercel AI Gateway.
- [Jev reranking is not a free win](https://x.com/GoSailGlobal/status/2100877682972258619) - Search reranking: a measured run over 33,047 catalog entries, 164 real queries, and 9,831 graded pairs reports that Jev reranking alone did not beat vector retrieval.
- [An early-access test of TypeSafe's Jev](https://lindfors.no/blog/a-first-look-at-typesafes-jev/) - Independent trial: measures calibrated judgments on early-access Jev and reports the resulting cost per decision.
- [jevcal](https://github.com/abhixhek/jevcal) - Model evaluation: fits a per-question confidence threshold to a target accuracy on your own labeled data, verifies it on a held-out split, reports how much traffic still has to escalate to an LLM, and fails CI when a model update breaks the locked thresholds.
- [WindTunnel](https://github.com/nekuda-ai/WindTunnel) - Browser-agent benchmark: measures WebMCP against other browser-agent interfaces, with Jev appearing as one of the compared configurations.
- [jev-eval](https://github.com/Shogo-nfrealmusic/jev-eval) - Third-party check: compares Jev against GPT-4o-mini and Claude Sonnet 4.5 under identical conditions on the same judgment task.
- [minutes](https://github.com/silverstein/minutes) - Meeting notes: local-first transcription app whose live voice path runs its evaluations through Jev.
- [jev-orderby-bench](https://github.com/yodablocks/jev-orderby-bench) - Model evaluation: measures whether a SQL ORDER BY over a Jev probability is defensible (pairwise inversion, Score ordinality against a human grade, calibration, wording invariants, sort-key ties) under a pre-registered gate that jev-1.13.0 passes on 20 Newsgroups topics and fails four of six conditions on Amazon ESCI product relevance, and shows a DuckDB extension's default 40-row batching fails the ranking gate that one row per request passes.
- [jev-ood-calibration](https://github.com/scienthoon/jev-ood-calibration) - Model evaluation: independent calibration test of Jev on 900 rule-generated support tickets it cannot have seen plus three public benchmarks, publishing every raw response, ECE against a simulated noise floor, temperature refit, and the per-type sign of miscalibration (Choice and Score overconfident, Boolean underconfident).
