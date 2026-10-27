# Data permission requests

Status log (update when sent or answered):

| Platform | Sent | To | Reply |
|---|---|---|---|
| Kalshi | | (verify contact; try the API/developer support channel in the Kalshi help center, or support@kalshi.com) | |
| Polymarket | | (verify contact; try support@polymarket.com, or the contact listed in the Terms of Use) | |

---

## Kalshi

**Subject:** Written permission request: non-commercial research on market calibration

Hello Kalshi team,

I'm an independent data scientist working on a non-commercial public research project: *"Are Prediction Markets Well Calibrated?"* It asks a simple question. When a market prices an event at 70%, does that event happen about 70% of the time? The project compares several platforms across thousands of resolved markets and includes the 2026 midterms.

Your Data Terms of Use and Developer Agreement require prior written authorization for this kind of use, so I'm asking for that permission. Specifically, I would like to:

1. Retrieve settled-market metadata, hourly candlesticks and trades through your public API (historical endpoints included), within your rate limits.
2. Store this data privately for analysis. I would **not** redistribute raw or cached Kalshi data sets.
3. Publish **aggregate results only**: calibration curves, Brier scores and summary charts, with "Source: Kalshi" attribution and a not-investment-advice disclaimer.
4. Use AI-assisted coding and analysis tools (e.g. an AI coding assistant) to write the analysis code and process the data. This would not include training any model on Kalshi data.

The code will be open source, with no raw data in the repository. I'm happy to share the draft with you before publication, to accept any attribution or scope conditions you prefer, and to delete the stored data when the project ends.

The first part is planned for around November 20, 2026, so a reply in the next couple of weeks would be greatly appreciated.

Thank you,
John Pospisil
github.com/johnpospisil/prediction-market-calibration

---

## Polymarket

**Subject:** Written permission request: non-commercial research on market calibration

Hello Polymarket team,

I'm an independent data scientist working on a non-commercial public research project: *"Are Prediction Markets Well Calibrated?"* It asks whether events priced at X% happen about X% of the time, across thousands of resolved markets on several platforms, and includes the 2026 midterms.

Section 4.2 of your Terms of Use asks for written agreement before data is accessed through your API, so I'm requesting permission to:

1. Retrieve resolved-market metadata (Gamma API) and price history (CLOB `prices-history`) within your rate limits.
2. Store this data privately for analysis, without redistributing raw data sets.
3. Publish **aggregate results only** (calibration curves, Brier scores, summary charts), attributed to Polymarket, with a not-investment-advice disclaimer. No individual trader or wallet would be named.
4. Use AI-assisted coding and analysis tools to write the analysis code and process the data, without training any model on it.

For trade-level analysis I plan to use public Polygon on-chain data. I'd welcome your view on that as well.

The code will be open source, with no raw data in the repository. I'm glad to share a draft before publication. The first part is planned for around November 20, 2026.

Thank you,
John Pospisil
github.com/johnpospisil/prediction-market-calibration
