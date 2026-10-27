# CLAUDE.md — Project 34: Are Prediction Markets Well Calibrated?

Spec: [34-prediction-market-calibration.md](34-prediction-market-calibration.md). Companion: Project 24 (`../data-planning/24-midterm-polling-postmortem.md`), built as a sibling repo at `../midterm-polling-2026`.

## Role and voice

Act as a senior data scientist whose priority is making results understandable to the general public, not only to other data scientists. Every analysis has to be correct first and then explainable to a curious non-expert.

**Plain-language rules (apply to the report, chart titles, captions and README):**
- Lead with the finding, in one sentence a non-expert could repeat at dinner. Put the method after it.
- Make probabilities concrete: "Of 1,000 events the markets priced at 70%, about 680 happened" rather than "calibration error of 0.02".
- Define a technical term in the sentence where it first appears (Brier score = "a 0–1 penalty for being confidently wrong; lower is better, like golf"). Use a weather-forecast analogy for calibration.
- Chart titles state the takeaway ("Markets are slightly too confident about long shots"), and subtitles say what is plotted. Every chart gets alt text.
- Use colorblind-safe palettes (load the `dataviz` skill before any chart), make charts readable on a phone, and label lines directly instead of relying on legends where possible.
- Describe uncertainty in words as well as intervals ("we're fairly confident", "this could be noise").
- Report aggregate patterns only and never accuse any individual trader. Every published page includes a "Not investment advice" disclaimer.

## Decisions (made 2026-10-27)

| Decision | Choice |
|---|---|
| Poll/forecast data | Build Project 24 as its own repo (`../midterm-polling-2026`) in parallel |
| Scheduled snapshots | GitHub Actions cron (both repos) |
| Release | **Two parts**: Part 1 "Are markets calibrated?" (~Nov 20); Part 2 "Polls vs markets: who got 2026 right?" (~Dec 16, joint with P24) |
| Venue | Quarto site on GitHub Pages, with the interactive explorer embedded |

## Timeline

Today is Tue 2026-10-27. Election day is **Tue 2026-11-03**. The external waits that limit how fast this can go are marked ⏳.

| Dates | Phase | Prompts | Hard deadline? |
|---|---|---|---|
| Oct 27–29 | Bootstrap, access check, **daily snapshotters live** (markets + polls/forecasts) | 0, 1, 2, B1 | **Yes: by Thu Oct 29**, so there are ≥5 daily snapshots before the election |
| Oct 30–Nov 2 | Historical ingest, market table, calibration v1, election-night mode ready | 3, 4, 5, 6 | Election-night mode by **Mon Nov 2** |
| Nov 3–5 | ⏳ Election night: 5–15 min snapshots, on-chain trades. Light work: categories | 7 | — |
| Nov 4–10 | Longshot bias, robustness, whales, cross-platform matching | 8, 9, 10 | — |
| Nov 10–17 | Market explorer, Part 1 article, QA | 11, 12, 13 | — |
| ~Nov 18–20 | **Publish Part 1** | 13 | — |
| Nov 10–24 | ⏳ Race calls arrive (most within days; slow House counts take weeks). P24 poll table + results ingest; provisional scorecard | B2, 14 | — |
| Dec 1 | ⏳ Possible Georgia runoff (verify which races go to a runoff) | — | — |
| ~Dec 1–15 | ⏳ States certify (most by early Dec; California, about 38 days after the election, ≈ Dec 11; verify stragglers). Final scoring | 15 | — |
| ~Dec 16–18 | **Publish Part 2** jointly with P24 | 15 | — |

**While waiting** (Nov 20 to mid-Dec), use the gap for stretch goals (prompt 16): sports markets vs sportsbook odds, economic-data markets vs consensus forecasts, or a live weekly calibration dashboard.

**Line up a reviewer now.** The spec calls for review by a finance or forecasting researcher. Reviewers take a week or more to reply, so send the request before Nov 10.

## Working conventions

- Python via `uv`; package at `src/pmc/`; layout follows spec §7. `make` targets: `ingest`, `build`, `models`, `figures`, `report`, `test`.
- Raw API responses are cached to `data/raw/<platform>/` (gitignored, except snapshots, which are committed to the `snapshots` branch as gzipped JSON or Parquet). Processed tables go to `data/processed/*.parquet`.
- Ingest code is rate-limited, retries with backoff, can resume after interruption and is idempotent. Record `fetched_at` (UTC) on every row.
- Tests (pytest): binary conversion of multi-outcome markets, calibration binning, horizon selection with no look-ahead, and pinned Brier scores on a toy dataset.
- Record each platform's terms of use and regulatory status in `DATA.md`, **dated**. Re-check before publishing.
- Use the `superpowers:test-driven-development` skill for model code, `dataviz` before any chart, `data:validate-data` before publishing, and `artifact-design` for any HTML deliverable.

## Checkpoint rule (applies to every prompt)

At the end of each prompt, **stop and present the checkpoint**: show the listed deliverables (chart images, tables, links, counts), state anything surprising, and ask the listed questions. Don't start the next prompt until the user replies. Then update the "Status" section below.

---

## Prompts

Copy each prompt into Claude Code in order. Track A is this repo; Track B is Project 24 (`../midterm-polling-2026`).

### Prompt 0: Bootstrap (Oct 27)
> Initialize this project per CLAUDE.md and spec §7: `git init`, `uv init` with pyproject (httpx, polars, pyarrow, duckdb, pydantic, tenacity, statsmodels, scipy, matplotlib/plotly, pytest), `src/pmc/` skeleton with empty modules, Makefile, `.gitignore`, README stub, DATA.md stub. Create the GitHub repo with `gh` (ask me public vs private first) and push. Do the same minimal bootstrap for `../midterm-polling-2026` using spec 24 §7 (package `src/mp/`).

**Checkpoint:** both repo URLs and a `tree` of each. Ask: public or private? Which GitHub account or org?

### Prompt 1: Day-one access check + regulatory status (Oct 27–28)
> Run spec §0. For Polymarket (Gamma + CLOB `prices-history`), Kalshi (public market-data endpoints, candlesticks, trades), Manifold, and PredictIt, fetch one *resolved* market end to end and save the raw response under `data/raw/_probe/`. Record for each: endpoints, auth needed, rate limits, history granularity and depth, whether trader identities are exposed, and terms-of-use clauses on data reuse/redistribution (quote and link). Research and write a dated regulatory/US-availability note for each platform as of today. Check Polygon on-chain options for Polymarket trades (public subgraph, Dune, direct RPC on the CTF Exchange contract) and their terms. Write all of it to DATA.md.

**Checkpoint:** a one-screen table (platform × access/auth/history depth/identities/terms risk). Flag any terms that block publishing derived data. Ask: should we create a Kalshi account and API key if needed? Is a Dune account OK?

### Prompt 2: Midterm market snapshotter, live by Oct 29 ⚠️
> Build `src/pmc/ingest/snapshot.py`: discover every 2026 midterm market (Senate, governor, House seats, chamber control, popular-vote and turnout markets) on Kalshi, Polymarket, Manifold and PredictIt (if available). For each market, snapshot best bid/ask, last/mid price, volume, open interest and top-of-book depth, with `fetched_at`. Keep a registry `data/reference/midterm_markets.csv` (platform, market id, race id like `SEN-PA-2026`, side). Add a GitHub Actions workflow that runs daily (and on manual dispatch) and commits gzipped output to a `snapshots` branch. Run it once now. Note in DATA.md which of this data can be backfilled later and which can't (e.g. order-book depth).

**Checkpoint:** the first snapshot's per-platform market counts, a link to the green workflow run, and the registry rows for 3 sample races. Ask: should any race types be added or dropped?

### Prompt B1 (Track B): Polls & forecasts snapshotter, live by Oct 29 ⚠️
> In `../midterm-polling-2026`: write its CLAUDE.md from spec 24 (same voice and checkpoint rules as this file). Then build a daily GitHub Actions snapshotter capturing (a) race-level polling averages and (b) forecast-model win probabilities from public sources that are currently active for 2026 (research which ones exist; check each one's terms and robots.txt), plus (c) Wikipedia 2026 poll tables (CC BY-SA). Use the same race ids as `data/reference/midterm_markets.csv` in Project 34. Run once now.

**Checkpoint:** a list of sources with their terms status (OK / unclear / no) and race coverage per source. Ask me which forecasters to include and whether to skip any source whose terms are unclear.

### Prompt 3: Election-night high-frequency mode (by Nov 2) ⚠️
> Add an election-window workflow for both repos: from Nov 3 18:00 ET to Nov 5 06:00 ET, snapshot midterm markets every 5–10 min. GitHub cron is best-effort and can be delayed, so use chained ~5h jobs that loop internally. Capture Polymarket on-chain trades for midterm markets over the same window (Oct 20–Nov 10) via the method chosen in prompt 1. Do a 30-minute dry run today.

**Checkpoint:** dry-run row counts per interval with no gaps, and estimated storage for the full window. Confirm the auto-stop date.

### Prompt 4: Historical ingest (Oct 30–Nov 1)
> Implement `ingest/manifold.py`, `polymarket.py`, `kalshi.py` and `polygon_trades.py` to pull **all resolved markets** with metadata, resolution and full price history (hourly where available, else daily), cached and resumable. Polymarket trades come from on-chain data with trader addresses. Run the full backfill in the background and report progress.

**Checkpoint:** resolved-market counts by platform × year, total GB, and one sample price-path chart per platform. Ask: is there a start-date cutoff (e.g. drop pre-2021 Polymarket)?

### Prompt 5: Market table, binary conversion, exclusions (Nov 1)
> Build `build/markets.py` and `build/prices.py`: a unified market table (spec §4.1), conversion of multi-outcome markets to binary contracts, exclusion of voided, disputed, ambiguous, N/A-resolved and never-traded markets, and price-at-horizon extraction (1d/1w/1m before resolution, with no look-ahead, using the last trade or mid before the cutoff). Write tests first. Hand-verify the resolution of a random 30 markets against the platform pages.

**Checkpoint:** an exclusion waterfall ("Started with N → dropped X voided → … → final N"), the 30-market spot-check result, and the test summary.

### Prompt 6: Calibration v1 + hero chart (Nov 1–2)
> Implement `models/calibration.py` and `brier.py`: reliability diagrams by platform at each horizon with bootstrap (or Wilson) intervals, and the Murphy decomposition of the Brier score (reliability, resolution, uncertainty). Produce the hero chart v1 (Kalshi / Polymarket / Manifold reliability diagrams with the diagonal and bands) following the plain-language rules.

**Checkpoint:** the hero chart, a plain-English headline in three candidate phrasings, and a table of Brier components. Ask: which headline framing works best? Is anything surprising?

### Prompt 7: Categories + calibration by category (Nov 3–5, light work during election week)
> Build `build/categories.py`: rule-based categories (politics, sports, economics, crypto, culture, science/tech, other) mapped from platform tags and keywords. Export a stratified sample of 100 for my manual review. Then create chart 2: calibration small multiples by category.

**Checkpoint:** `review/categories_sample.csv` for me to correct (I'll mark errors), then chart 2. Ask: should categories be merged or split?

### Prompt 8: Longshot bias + robustness (Nov 5–6)
> Implement `models/longshot.py`: a logit regression of outcome on logit(price), testing the slope ≠ 1 and the behavior at the extremes, by platform and category. Robustness checks: volume-weighted vs equal-weighted, excluding thin markets (choose a volume threshold and show sensitivity), and each horizon. Include the real-vs-play-money comparison (Manifold vs the others).

**Checkpoint:** a single "robustness grid" table (does the finding survive each check?) and a one-paragraph plain-English explanation of favourite-longshot bias with a betting example. Ask: would this surprise a general reader, or is it the expected result?

### Prompt 9: Whale event study (Nov 6–8)
> Implement `models/whale_events.py` on Polymarket on-chain trades: define large trades as the top 0.1% by USD size (also test top 1%) and run an event study of price paths over −1h to +1w, with permanent vs temporary impact at 1h/1d/1w and bootstrap bands. Separate buys from sells, and pre-election from election-window trades. Chart 3. Aggregate only; identify no wallet.

**Checkpoint:** chart 3, the persistence numbers, and the plain-English answer to "do whales move prices, and does it stick?". Confirm the wording stays at the aggregate level.

### Prompt 10: Cross-platform matching + spreads (Nov 8–10)
> Implement `build/match_events.py`: hand-match the top 50 events by volume, then fuzzy-match the rest (embedding or TF-IDF similarity on question text + resolution date). Export candidates for my review. For approved pairs, compute spread distributions and convergence half-lives (`models/cross_platform.py`). Chart 5.

**Checkpoint:** `review/match_candidates.csv` (I approve/reject), then chart 5 and the median spread and half-life. Ask: should the explorer feature any example pairs?

### Prompt 11: Market explorer (Nov 10–13)
> Build the interactive explorer (spec §6) as Observable JS inside the Quarto site, or as a small static app in `app/`: search/pick a market and see its price path, the resolution marker, and matched markets on other platforms. Precompute compact JSON. Make it mobile-first and accessible (keyboard navigation, good contrast).

**Checkpoint:** a local preview link plus screenshots at desktop and phone widths. Ask: which 5 markets should be featured as the default examples?

### Prompt 12: Part 1 article (Nov 12–16)
> Write `report/index.qmd`: "Priced In? Part 1: Are prediction markets well calibrated?" Follow the plain-language rules: a finding-first intro, the weather-forecast analogy, the hero chart early, then category, longshot, whale, cross-platform and real-vs-play-money sections, an embedded explorer, and a methods appendix for experts. Include the dated regulatory note and the disclaimer. Set up GitHub Pages deploy via Actions (draft, not public yet).

**Checkpoint:** a draft link and the reading-grade score of the main text (target ≤ grade 10). Ask: send to the reviewer now? Which pieces should be cut?

### Prompt 13: QA + publish Part 1 (Nov 17–20)
> Run the `data:validate-data` checklist across the analysis. Reproduce from a clean clone with `make all`. Re-check platform terms and regulatory status. Incorporate reviewer feedback if received. Publish to GitHub Pages. Draft distribution posts per spec §9 (a Hacker News title, a Bluesky/Twitter thread, a forecasting-Substack pitch, a Manifold community post).

**Checkpoint:** the live URL, QA results, and the post drafts for my approval. Nothing is posted without my sign-off.

### Prompt B2 (Track B): P24 poll table + results ingest (Nov 10–24)
> In `../midterm-polling-2026`, follow its CLAUDE.md through the poll table, pollster table and results ingest: AP or state-office calls as *provisional*, with a status column (`called` / `certified`) and source + date. Export final pre-election polling averages and forecast probabilities per race in the shared race-id format for Project 34.

**Checkpoint:** a coverage table (races with market + polling average + forecast + result status). Ask: should House races with thin polling be dropped from the scorecard?

### Prompt 14: Provisional midterm scorecard (Nov 17–24)
> Implement `models/midterms.py`: for every race covered by markets and P24, compute Brier score and log loss for each market platform, the polling average (converted to win probability with a documented method), and each forecaster, at matched times (final pre-election snapshot, 1 week out, 1 month out). Use called results and label everything PROVISIONAL. Chart 4: scorecard bars with bootstrap intervals, plus a race-by-race dot chart.

**Checkpoint:** chart 4 (provisional) and a "who called it best" sentence with its uncertainty. Note how few races were actually close, since that limits statistical power.

### Prompt 15: Final scoring + Part 2 publish (≈ Dec 11–18, after certification)
> Swap in certified results (diff them against the provisional calls), rerun the scorecard, and write Part 2 "Polls vs markets: who got 2026 right?" jointly with P24's post-mortem, cross-linked. Then do QA, publish, and draft distribution posts.

**Checkpoint:** the provisional-to-final diff, the final chart 4, the live URL, and post drafts for approval.

### Prompt 16 (optional, while waiting Nov 20–Dec 11): stretch goals
> Pick one with me: sports markets vs sportsbook closing lines, economic-data markets (CPI, jobs) vs consensus forecasts, or a weekly live calibration dashboard (GitHub Actions cron + Pages).

---

## Status

- 2026-10-27: Plan written.
- 2026-10-27: Prompt 0 done. Public repos: github.com/johnpospisil/prediction-market-calibration and github.com/johnpospisil/midterm-polling-2026 (Python 3.13, uv, smoke tests pass). Next: Prompt 1.
