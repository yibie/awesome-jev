# Data Labeling & Curation

Use this category for programs where Jev annotates, filters, deduplicates, or triages data at scale, replacing slower or costlier human and LLM labeling steps.

## Submission format

```md
- [Name](URL) - Industry: one-sentence description of the Jev use case.
```

## Entries

- [jev-align (Sutro)](https://github.com/sutro-sh/jev-align) - Dataset engineering: evaluates CSV, Parquet, and JSONL rows with Jev `Choice`, `Score`, or `Boolean` decisions, sends ambiguous and audit samples to a human, and uses accepted human labels to optimize the saved definition with GEPA.
- [jev-curate](https://github.com/AkashPriyadarshii/jev-curate) - Dataset engineering: sifts synthetic JSONL and Parquet rows using Jev Noul checks and calibrated confidence scores, streaming passed records and rejections straight to disk.
- [typeful-triage](https://github.com/cephalization/jev-triage) - Open-source maintenance: multiplayer triage dashboard where Jev answers a fixed set of typed questions per issue — kind, severity, urgency, duplicate, and next step — and every human correction is kept and shown back to the model on later runs.
- [jlink](https://github.com/keltokhy/jlink) - Research data: links records under a plain-English match rule using Jev Noul pair judgments, with local candidate blocking and match resolution.
- [jgrep](https://github.com/keltokhy/jgrep) - Data filtering: filters text, structured records, functions, and diff hunks against plain-English descriptions using Jev Noul judgments.
- [jevgrep (allebee)](https://github.com/allebee/jevgrep) - Log triage: filters logs and other text streams, including live `tail -f` output, by asking Jev one Noul per line against a plain-English question and printing lines at or above a probability threshold, with a hand-labelled benchmark against Claude in the repository.
- [jev-research-pipeline](https://github.com/shimo4228/jev-research-pipeline) - Research monitoring: asks Jev Noul gates and Score dimensions per (paper, research question) on each daily fetch through Pydantic AI's typesafe model, keeps sources above a code-side threshold, and hands them to Qwen for question-centric Obsidian notes; offline tests replay recorded cassettes.
- [Jag](https://github.com/xyzzzh/Jag) - Visual annotation: a Qwen3.5-0.8B model that predicts a continuous bounding box from an image and referring expression in one forward pass, reporting a measured 3.62× single-request speedup over LocateAnything ([paper](https://arxiv.org/abs/2610.13239)).
- [jevextract](https://github.com/gabazureus/jevextract) `{type: library}` - Information extraction: LangExtract alternative where code proposes candidate spans with exact offsets and Jev answers one `Choice` per span (a schema class or none) plus a `Noul` per sentence-level class, keeping answers above a per-class threshold and flagging close calls for review, with a published benchmark measuring 10–26× lower cost than LangExtract on Gemini 3.5 Flash but lower F1 (84.2 vs 88.5 on its bilingual jx-bench).
- [JevSpan](https://github.com/lzq-0529/jev-span) `{type: library}` - Information extraction: zero-shot named entity recognition that splits text at punctuation, asks Jev one `Choice` over every candidate window per entity type, verifies each nominee with a second `Choice` (the type, none, mixed or partial) and settles its boundary with a third, averaging 73.7 strict F1 across 12 Chinese and English NER benchmarks against 72.1 for direct extraction with Qwen3.8-27B.
- [Jev Account Filter](https://github.com/caiweihan/jev-account-filter) - Research dataset curation: ranks first-page video titles with Jev `Noul`, selects Top-N thumbnails, then uses an independent account-category `Choice` with profile metadata to screen video-platform accounts, reporting $0.565 in API cost for 2,140 accounts.
- [JevNER](https://github.com/vortezwohl/JevNER) - Named entity recognition: a Python SDK that turns typed judgments into nested entity trees, so zero-shot multilingual NER is posed as questions rather than trained as a tagging model.
