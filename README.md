# Priced In? Are Prediction Markets Well Calibrated?

When a prediction market says something has a 70% chance of happening, does it happen about 70% of the time? This project checks that across thousands of resolved markets on **Kalshi**, **Polymarket** and **Manifold** (play money). It also looks at whether big traders move prices and how the markets did against polls and forecasters in the **2026 US midterms**.

Status: in progress. Part 1 (calibration) is due around Nov 20, 2026, and Part 2 (midterms) around mid-December 2026.

*Not investment advice.*

## Reproduce

```bash
uv sync
make test
make all
```

Data sources and terms of use: see [DATA.md](DATA.md).
