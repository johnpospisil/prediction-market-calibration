# Data sources, terms and status

Every status note is dated. Re-check before publishing. This file is research notes, not legal advice.

Probe responses (one resolved market per platform, end to end) are in `data/raw/_probe/`, which is gitignored and never published.

## Access (checked 2026-10-27)

| Platform | Auth | Market metadata + resolution | Price history | Trades | Trader identities | Rate limit |
|---|---|---|---|---|---|---|
| **Polymarket** | None | Gamma `/markets`, `/events` (`closed`, `umaResolutionStatus`, `outcomePrices`) | CLOB `/prices-history?market=<token_id>`: `interval=all&fidelity=1440` gives the full life at daily resolution; `startTs/endTs` windows of **≤15 days** at down to 1-minute fidelity | data-api `/trades?market=<conditionId>`, **capped at offset 10,000** (full history for large markets needs on-chain data) | Yes: `proxyWallet` (pseudonymous) | Not advertised |
| **Kalshi** | None for market data | `/markets`; markets settled before the cutoff (currently 2026-08-28; see `/historical/cutoff`) move to `/historical/markets` | `/historical/markets/{ticker}/candlesticks` (60 or 1440 min; bid/ask/price OHLC, volume, OI); live markets via `/series/{s}/markets/{t}/candlesticks`. Checked back to 2024 (`PRES-2024-DJT`) | `/markets/trades`, `/historical/trades` | **No** | Tiered (see docs) |
| **Manifold** | None | `/v0/markets`, `/v0/search-markets?filter=resolved` (`resolution`, `resolutionTime`) | Rebuilt from bets (`probBefore`/`probAfter`) | `/v0/bets?contractId=` (paginate with `before`/`beforeTime`) | Yes: `userId` | 500 req/min/IP |
| **PredictIt** | None | Live only: `/api/marketdata/all/` (229 markets on 2026-10-27). **No list of closed markets and no resolutions** | `/Resource/DownloadMarketChartData?marketid=&timespan=90d`: daily OHLC CSV, about the final 90 days, closed markets included | No | No | **5 req/min** |

### Data-quality notes from the probes
- **Kalshi** now lists huge numbers of auto-generated multi-leg "parlay" markets (`KXMVE…`, `mve_collection_ticker`, `market_type` binary). They must be excluded or analysed separately.
- **Manifold** markets carry `token` (`MANA` vs `CASH`). Sweepcash (real-money mode) ran from Sept 2024 to 2025-03-28. Keep only `MANA` for the play-money comparison.
- **Polymarket** multi-outcome events are `negRisk` groups of binary markets, so they are already binary. The Goldsky public orderbook subgraph is **deprecated** ("stale and incorrect") after Polymarket's V2 migration. Public Polygon RPC (e.g. `polygon-bor-rpc.publicnode.com`) works for direct `eth_getLogs`; Dune is the other on-chain option.
- Manifold's free bulk dumps (markets, bets, comments) date from **July 2024**, are for personal and non-commercial use only, and are a useful bootstrap before API top-up.

## Terms of use (checked 2026-10-27): the main risk

| Platform | What the terms say | Risk for this project |
|---|---|---|
| **Kalshi** | *Data Terms of Use* (official PDF): use only "in the form in which it is presented on the Website", for "personal use for non-commercial purposes". Without prior written authorization, the terms prohibit "collecting, copying… downloading… publishing, … creating derivative works, … scraping, compiling (… systematic retrieval to create collections, compilations, databases…) or conducting 'text and data mining'". They also say "use of any Kalshi Data… in connection with the use of [AI] technologies… to generate any… derived works… is expressly prohibited." *Developer Agreement v1.1* §3: API use "is expressly limited to facilitating a member's own trading"; §3.1 prohibits "collecting, caching, aggregating, or storing data… except for… your own trading" and sharing with third parties without written authorization. | **High.** Bulk collection, analysis with AI tools and publication all need written permission. |
| **Polymarket** | Terms of Use (Adventure One QSS, Inc.; effective 2026-08-11; full text supplied by the user on 2026-10-27; Panama law). Prohibited: "data mining tools, robots, crawlers, or similar data gathering and extraction tools to scrape or otherwise remove data from the Site, any other Interface, or Features", and collecting information "for any unauthorized purpose". The **Data clause** bars access to Data "directly or through an API, or any other means, including on-chain, whether in raw, derived, aggregated, or anonymized form" **only for "Capital Market Clients"** (brokers, hedge funds, prop/trading firms, fintechs, banks, exchanges and their affiliates) **and market data distributors**, unless agreed in writing. Redistribution is barred only *to* those groups. The terms reserve the right to "grant access to public on-chain infrastructure". They say nothing about AI. US persons may use Content Features but not trade. (A third-party audit, Daatan/retro#937, overstated these restrictions.) | **Low–medium** for an individual non-commercial researcher using the documented public APIs at moderate rates and publishing aggregates. Don't crawl the website. Re-check if the user's status changes (e.g. finance employer). |
| **Manifold** | API docs: academic research, personal projects and non-commercial use are permitted. Scraping outside the API and evading rate limits are prohibited. Commercial AI/ML training needs a license. Redistribution is not addressed. Bulk dumps are for personal and non-commercial use only. | **Low.** Publish aggregates; don't re-host raw bets. |
| **PredictIt** | Not retrievable (client-rendered). Third-party summaries: data licensed for non-commercial use, scraping and automated extraction prohibited. robots.txt: `Allow: /`. | **Medium.** Verify in a browser. Minor source in any case. |

Sources: [Kalshi Data Terms](https://kalshi-public-docs.s3.amazonaws.com/kalshi-data-terms-of-service.pdf), [Kalshi Developer Agreement](https://kalshi-public-docs.s3.amazonaws.com/Kalshi-Developer-Agreement.pdf), [ToS audit quoting Polymarket §4.2](https://github.com/Daatan/retro/issues/937), [Manifold API docs](https://docs.manifold.markets/api), [Manifold data dumps](https://docs.manifold.markets/data), [rpredictit README](https://rdrr.io/cran/rpredictit/f/README.md), [Alphascope on PredictIt terms](https://www.alphascope.app/blog/predictit-api).

## Regulatory / US availability (as of 2026-10-27)

- **Polymarket:** two entities. *Polymarket US* (QCX LLC) is a CFTC-regulated Designated Contract Market, launched 2025-12-03 with fully collateralized contracts only. The *international platform* is not CFTC-regulated and remains geoblocked for US users (2022 CFTC settlement). Polymarket filed with the CFTC on 2026-04-28 to open the main platform to US users (pending). A CFTC probe was dropped in July 2025, and a new one was reported in June 2026. Reports differ on whether election markets are offered on Polymarket US. Our data comes from the international platform. [gamblinginsider](https://www.gamblinginsider.com/?p=106291), [Cointelegraph](https://cointelegraph.com/news/polymarket-cftc-approval-main-platform-us-report), [The Block](https://www.theblock.co/post/380384/homegrown-nyc-startup-polymarket-resume-us-operations-cftc-reversal)
- **Kalshi:** CFTC-regulated DCM. Election contracts have been listed since the 2024 court win over the CFTC. Sports contracts face state suits and cease-and-desists (NV, NJ, MD in 2025; New Mexico June 2026; Connecticut August 2026). The preemption question may reach the Supreme Court. No Sept–Oct 2026 rulings found. [The Block](https://theblock.co/news/regulation/2026-08-27-connecticut-sues-kalshi-412870), [Bloomberg Law](https://news.bloomberglaw.com/litigation/kalshis-prediction-contracts-spark-wide-ranging-legal-battle), [SBC Americas](https://sbcamericas.com/2026/06/05/new-mexico-torrez-legal-action-kalshi/)
- **PredictIt:** operates under CFTC no-action relief (Letter 14-130, amended by 25-20 on 2025-07-14). The 5,000-trader cap was removed and the per-person limit raised to $3,500; the operator is moving to the Prediction Market Research Consortium. [CFTC](https://www.cftc.gov/media/12501/FOIA_25-00304/download), [Bloomberg Law](https://news.bloomberglaw.com/antitrust/predictit-says-it-can-expand-political-trades-under-cftc-deal)
- **CFTC rulemaking:** a 2026-06-12 proposal would replace categorical event-contract bans with contract-by-contract public-interest review. Comments closed 2026-07-27. [Cahill](https://www.cahill.com/publications/client-alerts/2026-06-17-cftc-event-contract-proposal-outlines-the-way-ahead-for-prediction-markets)
- **Manifold:** play money only (Mana) since 2025-03-28. Mana can't be cashed out, only donated to charity at M100 = $1.

## Backfillable vs snapshot-only data

| Data | Backfillable later? |
|---|---|
| Polymarket prices (to 1-min), trades, resolutions | **Yes** (CLOB history + on-chain) |
| Kalshi prices (hourly bid/ask/last), trades, resolutions | **Yes** (historical endpoints) |
| Manifold prices, bets | **Yes** |
| PredictIt daily prices | Partly: final ~90 days only; closed markets must be identified while live |
| Full order-book depth (any platform) | **No.** Snapshot only |
| Polling averages and forecast-model probabilities by day | **Often no.** Snapshot only (Project 24) |
