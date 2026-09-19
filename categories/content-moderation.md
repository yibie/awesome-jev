# Content Moderation

Use this category for policy and abuse decisions over user-generated content at volume.

## Submission format

```md
- [Name](URL) - Industry: one-sentence description of the Jev use case.
```

## Entries

- [Jev Moderation Bot](https://github.com/brainstormity/Jev-Moderation-Bot) - Community moderation: Discord bot that scores incoming messages for phishing, spam, and social engineering with Jev and drives a four-stage escalation ladder, injecting pardoned messages back into context as verified-safe precedent.
- [jev-spam-eval](https://github.com/bitnovus/jev-spam-eval) - Spam filtering: zero-shot spam classification with Jev `Boolean` questions, benchmarked against TF-IDF baselines.
- [mastra-jev-moderation](https://github.com/CodeAlive-AI/mastra-jev-moderation) - AI assistants: Mastra input processor that asks Jev a `Boolean` "must this message be blocked?" plus a category `Choice` in one request, aborting the turn at 0.7 and failing open behind a deadline and circuit breaker; in production it blocked 9/9 hostile and 0/49 real messages at ~0.4 s median, about 4× cheaper than an LLM moderator.
- [Jev Chat for Twitch](https://github.com/ethanplusai/jev-chat-for-twitch) - Live chat filtering: bring-your-own-key Chrome extension that reads a Twitch channel's chat over the anonymous IRC WebSocket, asks Jev one category `Choice` per message in batches of 20, and shows a second column of only the messages matching a chosen intent (helpful, questions, funny, feedback); about 504 input tokens per message, roughly $0.15 per hour on a 2-message-per-second chat and $0.76 per hour at 50 per second.
