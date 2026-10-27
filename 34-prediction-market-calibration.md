# Project 34: Are Prediction Markets Well Calibrated?

**Backlog ID:** FI-5 · **Difficulty:** Medium · **Data access:** Open public market data (check terms) · **Estimated time:** 6 weeks · **Pairs with Project 24**

**Working title:** *Priced In? Calibration, Whales and the 2026 Midterms on Real-Money Prediction Markets*

**One-sentence pitch:** Collect the full price history of thousands of resolved markets on Kalshi and Polymarket (plus play-money Manifold as a comparison) to measure how well calibrated they are, whether large traders move prices, and how the markets compared with polls and forecasters in the 2026 midterms.

---

## 0. Day-one access check
- [ ] Polymarket: query the Gamma API (market metadata) and CLOB price-history endpoint for one resolved market. On-chain trade data is also public on Polygon (via a subgraph or Dune; check terms).
- [ ] Kalshi: check which market-data endpoints are public without authentication, and the API terms of use.
- [ ] Manifold: open API, no key, full market and bet histories.
- [ ] Record the state of each platform's US availability and regulatory status. **This changed in 2024–2025 (e.g. Kalshi's election contracts after its court case with the CFTC, Polymarket's return to US users); check before writing.**

## 1. The question

**Primary:** Across all resolved markets, when a market prices an event at X%, does it happen about X% of the time? How does calibration vary by platform, category (politics, sports, economics, culture), liquidity and time before resolution?

**Secondary:**
- **Favourite-longshot bias:** are low-probability outcomes overpriced (as in betting markets)?
- **Whales:** do very large trades move prices, and do those moves reverse (noise) or persist (information)?
- **Cross-platform gaps:** how big are price differences for the same event on different platforms, and how fast do they close?
- **2026 midterms:** markets vs polling averages vs forecast models: Brier score and log loss by race (using Project 24's poll data).
- **Real vs play money:** is Manifold (play money) as well calibrated as the real-money platforms?

**A finding that would be wrong if:** calibration curves lie on the diagonal for all platforms and categories, there's no longshot bias, and whale-driven moves persist (meaning large traders bring information).

## 2. Why now
- Prediction markets grew enormously in 2024–2026, expanding from politics into sports and economics, with large trading volumes and media coverage on election nights. **Check the latest volume figures.**
- Claims about market accuracy are mostly anecdotes about famous calls; systematic calibration analysis across thousands of markets is rare.
- Concerns about wash trading and manipulation on some platforms have been reported. **Check recent research before citing.**
- Prior work: Wolfers & Zitzewitz, *Prediction Markets* (JEP, 2004); studies of the favourite-longshot bias in betting markets.

## 3. Data sources

| Source | What it gives you | Grain | Where |
|---|---|---|---|
| **Polymarket APIs** | Markets, outcomes, resolution, price history; trades | market × time | Gamma and CLOB APIs (public), Polygon on-chain data |
| **Kalshi API** | Markets, prices, trades, resolution | market × time | Kalshi API (check public endpoints and terms) |
| **Manifold API** | Markets, bets, resolution (play money) | bet | manifold.markets API (open) |
| **PredictIt** | Historical political markets (where data is available) | market × day | Check access |
| **Polls and forecasts** | 2026 polling averages and forecasts | race × day | Project 24 pipeline |
| **Results** | Certified 2026 results | race | Project 24 pipeline |

## 4. Building the dataset

1. **Market table:** platform, market ID, question, category, open/close/resolution dates, outcome, total volume.
2. **Price histories:** time series per market (hourly or daily mid-price); trades for whale analysis (Polymarket on-chain gives trader addresses; Kalshi doesn't expose identities).
3. **Matching:** the same event across platforms (hand-matched for major events; fuzzy text matching + review for others).
4. **Categories:** rule-based + manual review.
5. **Checks:** resolution outcomes verified for a sample; exclude ambiguous or voided markets; handle multi-outcome markets (convert to binary contracts).

## 5. Method

- **Calibration:** bin predicted probabilities at fixed horizons (1 day, 1 week, 1 month before resolution); compare with realised frequencies; reliability diagrams with intervals; Brier score decomposition (reliability, resolution, uncertainty).
- **Longshot bias:** regression of outcomes on price (logit), testing deviations at the extremes.
- **Whale impact:** event studies of price paths around large trades (top 0.1% by size) on Polymarket; persistence at 1h, 1d, 1w.
- **Cross-platform:** spread distributions and half-lives of convergence.
- **Midterms:** Brier and log loss for markets vs polling averages vs forecasters, race by race.

### Robustness
- Weight by volume vs equally; exclude thin markets; different horizons.

### What you won't claim
That a specific trader manipulated a market. Report aggregate patterns.

## 6. Charts

| # | Chart | Purpose |
|---|---|---|
| **Hero** | **Calibration curves (reliability diagrams) for Kalshi, Polymarket and Manifold**, with the diagonal and confidence bands | The headline |
| 2 | Calibration by category (small multiples) | Where markets are good or bad |
| 3 | Price path around whale trades (event study with band) | Do whales move prices? |
| 4 | Midterms scorecard: markets vs polls vs forecasters (Brier score bars) | Who called it best |
| 5 | Cross-platform price spreads for the same events over time | Market efficiency |

**Interactive:** pick a market and see its price path, the resolution, and the same event on other platforms.

## 7. Repo skeleton

```
prediction-market-calibration/
  README.md, DATA.md, Makefile, pyproject.toml, uv.lock
  src/pmc/
    ingest/polymarket.py, polygon_trades.py, kalshi.py, manifold.py
    build/markets.py, prices.py, match_events.py, categories.py
    models/calibration.py, brier.py, longshot.py, whale_events.py, cross_platform.py, midterms.py
    viz/theme.py, figures.py
  tests/          # binary conversion, calibration binning, pinned Brier scores
  report/index.qmd
  app/
```

## 8. Milestones

| Week | Deliverable |
|---|---|
| Before Nov 3 | Pipelines running; snapshot midterm markets daily |
| 1 | Historical resolved markets ingest; calibration v1 |
| 2 | Categories; longshot bias; hero chart v1 |
| 3 | Whale analysis; cross-platform matching |
| 4 | Midterms comparison (with Project 24) |
| 5 | Article + market explorer |
| 6 | Review by a finance/forecasting researcher; publish |

## 9. Distribution
- Forecasting and rationalist communities (Manifold, Metaculus users, forecasting Substacks), finance Twitter/Bluesky, Hacker News, election analysts.
- Publish jointly with Project 24 as "polls vs markets: who got 2026 right?"

## 10. Risks and mitigations

| Risk | Mitigation |
|---|---|
| API terms and access | Check terms; prefer public on-chain data where terms are unclear |
| Market resolution disputes | Exclude disputed markets; document rules |
| Regulatory facts change | Dated status notes; update at publication |
| Not investment advice | Clear disclaimer |

## 11. Stretch goals
- Sports markets vs sportsbook odds.
- Economic-data markets (CPI, jobs reports) vs economist consensus forecasts.
- Live calibration dashboard updated weekly.
