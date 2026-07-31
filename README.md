# dbt Enterprise Models

A contractor-optimized dbt project template for rapid client onboarding: a fully working `staging` → `intermediate` → `analytics` pipeline for e-commerce revenue and marketing spend, backed by a synthetic demo dataset so it runs end-to-end out of the box — before you've connected a single real source.

The goal isn't to ship a connector for every platform a client might have. It's to hand you a **working reference pipeline** with the patterns (staging conventions, cross-platform unions, currency conversion, click attribution, incremental loading, test coverage) already solved once, correctly, so extending it to a client's actual sources is mostly copy-and-adapt rather than starting from a blank file.

## What's actually built

- **Revenue**: a `prod` custom database (customers, orders, order_items, products) plus Stripe (payments, refunds) — full order → payment → refund → revenue pipeline, with **multi-currency support** (Stripe payments settle in the customer's local currency; everything is converted back to a single reporting currency for BI).
- **Marketing spend**: Google Ads (campaigns → ad groups → ads → daily click/cost performance) and Facebook Ads (campaigns → ad sets → ads with daily performance), unified into one cross-platform shape in `int_marketing__combined`.
- **Attribution**: orders and web visits both carry a Google Click ID (`gclid`); `parse_gclid_ad_id` resolves it back to a campaign/ad, so revenue in `fct_transactions` and visits in `fct_visits` are directly joinable to spend in `agg_marketing` — the thing every marketing dashboard actually asks for.
- **Channel-level reporting**: `marketing_channel_taxonomy` classifies both GA4 sessions (`int_session__marketing_channel_classification`) and ad platform campaigns (`int_marketing__channel_classification`, by pattern-matching campaign names) into the same channel groupings, so `agg_channel` can show spend/clicks/revenue/ROAS/ROI side by side per channel — not just per platform.
- **An incremental fact table**: `fct_visits` is the reference example for `materialized='incremental'` — raw, ever-growing first-party visit events, as opposed to GA4's pre-aggregated (and fully-refreshed) sessions.
- **Customer lifetime value with forward projection**: `agg_customer_lifetime_value` computes historical LTV plus a simple 1/3/5-year projection (average order value × purchase frequency, held constant) — a generic baseline every retaining-customer business can use immediately, meant to be swapped for a proper retention-curve or cohort model per client once there's enough order history to fit one.
- **Reference data (seeds)** — genuinely populated, not stubs:
  - `country_codes` (ISO codes, currency, region, primary timezone)
  - `currency_info` (symbols, decimal places)
  - `timezones` (core time zones with UTC offset and DST support)
  - `bank_holidays` (UK & Ireland 2015–2030)
  - `uk_outward_postal_codes` (UK postcode districts with town, county, lat/long)
  - `marketing_channel_taxonomy` (configurable channel groupings, regex-matched)
- **A synthetic demo dataset** (`seeds/example/**`, regeneratable via `scripts/generate_example_seeds.py`) standing in for a real ELT tool's landing tables, so the whole pipeline runs immediately — customers, orders, payments/refunds in five currencies, ad platform performance, GA4 sessions, and web visits, all referentially consistent.
- **Test coverage**: standard dbt tests, five custom generic tests (`tests/generic/`) — `positive_value`, `range_check`, `not_null_if_active`, `unique_if_active`, `accepted_values_if_status` — and `dbt_utils` tests (`expression_is_true`, `unique_combination_of_columns`, `at_least_one`), all wired to real columns, plus `relationships` tests across every fact/dimension foreign key. Source freshness is configured on `models/sources.yaml` (`dbt source freshness`).
- **SCD Type 2 snapshots** for exchange rates and product pricing.
- **Generic macros** (`macros/`): `safe_divide`, `parse_gclid_ad_id`, `cents_to_currency` (Stripe-style minor-unit amounts — unused by the demo data, which is already decimal, but a one-line fix for real client data), `pct_change` (period-over-period ratio for MoM/YoY comparisons), and `fiscal_year`/`fiscal_quarter` (client-configurable fiscal calendar, wired into `dim_date`).

## Extending it to a real client

This is deliberately not trying to be wide in the sense of "every ad platform pre-built." Two ad platforms and one payment processor already demonstrate every pattern a third or fourth connector would need — copying one more platform in teaches nothing new. What's actually client-specific is:

- **Adding a new source**: copy the closest existing staging folder (e.g. `staging/marketing/google_ads/` for another ads platform, `staging/commercial/stripe/` for another payment processor) and adapt the column list. Add the raw table to `models/sources.yaml`.
- **A different revenue shape**: this template's revenue model is one-off e-commerce orders. A subscription/SaaS client (MRR, churn) or a B2B funnel (leads → opportunities → closed-won) needs a genuinely different intermediate-layer pattern — build that per client rather than trying to generalize it here, since every business does it differently anyway.
- **Reporting currency**: set `vars.reporting_currency` in `dbt_project.yml` (defaults to `GBP`).
- **Fiscal calendar**: set `vars.fiscal_year_start_month` in `dbt_project.yml` (defaults to `1`, i.e. matches the calendar year).
- **Channel taxonomy**: edit `seeds/marketing_channel_taxonomy.csv` and re-run `dbt seed` — no code changes needed. Ad platform campaigns are classified by pattern-matching their name against the same taxonomy, which assumes a naming convention like `Google Brand Search` (see the comment in `scripts/generate_example_seeds.py`) — a client without one needs an explicit campaign-to-channel mapping seed instead.
- **Removing an unused source**: delete the staging folder; downstream models that don't depend on it are unaffected.
- **Fuller channel attribution**: `agg_channel`'s revenue side is gclid-based (Google Ads only) by design — Facebook and organic/email/referral revenue isn't attributed to a channel yet, since there's no cross-platform click-id equivalent or session-to-order join in this demo. Extend with Facebook's click-id equivalent, or a session-to-order identifier, once a client's data actually supports it.

## Project Structure

```
models/
├── staging/
│   ├── commercial/      # Stripe, GA4, exchange rates
│   ├── marketing/       # Google Ads, Facebook Ads
│   └── prod/            # Customers, orders, products, web visits
├── intermediate/        # Business logic: enrichment, currency conversion, attribution, cross-platform unions
└── analytics/           # Final BI-ready models (dim_, fct_, agg_*)
seeds/
├── *.csv                 # Reference data (country codes, currency, calendar, etc.)
└── example/**             # Synthetic demo dataset — see scripts/generate_example_seeds.py
snapshots/                # SCD Type 2 (exchange rates, product pricing)
tests/generic/             # Custom test macros
macros/                    # safe_divide, parse_gclid_ad_id, cents_to_currency, pct_change, fiscal_year, fiscal_quarter
analysis/                  # Ad-hoc queries (ignored in production runs)
scripts/                   # generate_example_seeds.py — regenerate the demo dataset
```

## Quick Start

1. **Clone the repo**
   ```bash
   git clone https://github.com/donovannevard/dbt-enterprise-models.git
   cd dbt-enterprise-models
   ```

2. **Install packages**
    ```bash
    dbt deps
    ```

3. **Load reference + demo data**
    ```bash
    dbt seed
    ```

4. **Connect to your warehouse**
    - Copy `profiles.yml.example` to `profiles.yml` (project root, gitignored) and fill in credentials via `.env` or your shell.

5. **Run the project**
    ```bash
    dbt run # Build all models
    dbt test # Run data quality tests
    dbt docs generate && dbt docs serve # View lineage & docs
    ```

To point this at a real client's data instead of the demo dataset, replace the `source()` targets in `models/sources.yaml` with their actual raw schema and drop the `seeds/example/` seeding step.

## Continuous Integration

`.github/workflows/dbt_ci.yml` runs on every PR and push to `main`, as two jobs:

1. **`validate`** — `dbt deps` + `dbt parse` with placeholder credentials. No warehouse connection needed, so it runs even on PRs from forks without secrets access. Catches config/YAML/Jinja/ref/source errors in seconds.
2. **`build`** — `dbt deps` + `dbt build --target ci` (seeds, snapshots, models, and tests, in DAG order) against a real Snowflake connection.

`build` needs these repo secrets (Settings → Secrets and variables → Actions):
`SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_TRANSFORM_ROLE`, `SNOWFLAKE_TRANSFORM_WAREHOUSE`, `DB_TRANSFORM_USER`, `DB_TRANSFORM_PASSWORD`, `DB_TRANSFORM_DATABASE` — the same names `profiles.yml.example` already expects.

**Point `DB_TRANSFORM_DATABASE` at a database dedicated to CI**, not your dev or prod one. Snapshot `target_schema` is fixed to `snapshots` regardless of target, so a shared database would let CI runs and real snapshot history collide. The CI database will accumulate data across runs — there's no automatic teardown by design (an automated `DROP` step is exactly the kind of thing you don't want misfiring against the wrong target), so clean it up periodically or use a low-cost/auto-suspend warehouse for it.

## Deployment
- Use dbt Cloud for scheduling, CI/CD, and team collaboration (recommended for most clients).
- Or run locally/on a server with GitHub Actions (see above) or Airflow.

## Support & Customisation
- Built and maintained by Donovan — freelance data contractor.
- For extensions (custom sources, advanced metrics, dbt Cloud setup, monitoring), get in touch.
