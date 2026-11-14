# Finance & Trading

Use this category for programs where Jev makes trading, investment, or market-judgment decisions.

## Submission format

```md
- [Name](URL) - Industry: one-sentence description of the Jev use case.
```

## Entries

- [Jevinik](https://github.com/unicodeveloper/jevocks) - Stock decisions: terminal that gathers live market evidence through Valyu and asks Jev whether a stock is likely to trade higher over the next 30 days.
- [jev_stock](https://github.com/sosopop/jev_stock) - Short-term forecasting: experimental Hong Kong stock framework that turns structured market state into a Jev decision on price direction, with a backtest script for the first trading day.
- [jev-trade](https://github.com/aowang-ai/jev-trade) - Crypto trading: asks Jev for a Choice of long or short on a Hyperliquid market each round, places that order, and runs the same loop across many assets.
- [Jev X Sentiment Analysis](https://github.com/brainstormity/Jev-X-Sentiment-Analysis) - Crypto decision support: ingests 50-1,000 tweets per request through statistical pre-processing and SQLite deduplication, then has Jev turn the surviving evidence into a decision card with entry ranges, stop losses, and targets, without executing trades.
- [jev-guard (klauswg)](https://github.com/klauswg/jev-guard) - Exchange risk operations: screens crypto exchange deposits and withdrawals with Jev triage (risk level, behavioral pattern, freeze probability) while hard rules veto and Java composes the final action, with a published 100-sample three-column calibration against a rules-only baseline.
- [jev-trader](https://github.com/jarrodwatts/jev-trader) - Trading: watches the Kuru MON-USDC book on Monad and asks Jev for a `Choice` between buy and sell every block, publishing 81 ms decision latency and $0.000004 of Jev cost per call from a live dry run.
- [ai-hedge-fund](https://github.com/virattt/ai-hedge-fund) - Quantitative finance: multi-agent AI hedge fund trading system featuring native JevLLM integration to execute fast typed decisions without parsing fragility.
- [Polymarket BTC 5m Jev trader](https://github.com/VGabriel45/polymarket-btc5m-jev-trading) - Prediction markets: a trading agent for Polymarket's five-minute BTC up/down markets that puts Jev in the decision layer behind a terminal UI.
- [sec-8k-filings-and-decision-models](https://github.com/magilliam27/sec-8k-filings-and-decision-models) - Finance research: asks one five-option Jev Choice how good or bad each of 26,962 S&P 500 8-K filings is for shareholders, and finds the probability-weighted rating has a rank correlation of +0.025 (95% interval +0.015 to +0.034) with the next two days' market-adjusted return.
- [JEV Trading Command Center](https://github.com/mars-tw/jev-trading-command-center) - Paper trading: a research app where Jev decisions drive a simulated broker, with no exchange order routing at all, so the decisions can be studied without risking anything real.
- [Jev Paper Trader](https://github.com/MojoAI-King/jev-paper-trader) - Paper trading: a fake hundred-thousand-dollar bankroll on real Polymarket and Kalshi markets with Jev as the judge, reading only public prices and placing no orders, to see whether a model fed by a research agent can pick.
