# Welcome to the Enterprise Analytics Project

This dbt project provides a production-ready analytics foundation for e-commerce, marketing, and operational data.

## Key Features

- **Marketing Ads Coverage**: Pre-built staging models for major platforms (Facebook, Google Ads, TikTok, Snapchat, Pinterest, Twitter/X, LinkedIn, Microsoft Ads, Reddit, Amazon Ads)
- **Commercial Sources**: Ready for Shopify, Stripe, Amazon Seller, eBay, and custom databases (`proddb/`)
- **Reference Data**: Seeds for countries, currencies, time zones, UK/Ireland bank holidays, postcode districts, and marketing channel taxonomy
- **Core Models**:
  - `dim_date` — auto-generated date dimension (2000-2030+)
  - Dimensions (`dim_*`), facts (`fct_*`), and aggregates (`agg_*`) in `analytics/`
- **Data Quality**: Generic tests for uniqueness, nulls, positives, ranges, and status-based checks
- **Macros**: Leverages `dbt_utils` and `fivetran_utils` for best practices

## Project Structure

- `staging/` — Raw → cleaned models, organised by source type
  - `commercial/` — E-commerce & payments
  - `marketing/` — Paid advertising platforms
  - `proddb/` — Custom database/website
- `intermediate/` — Business logic and joins
- `analytics/` — Final BI-ready tables (dimensions, facts, aggregates)
- `seeds/` — Reference data (countries, holidays, postcodes, etc.)
- `snapshots/` — SCD Type 2 tracking (add as needed)
- `tests/` — Generic and model-specific data quality tests

## Getting Started

1. Install packages: `dbt deps`
2. Load seeds: `dbt seed`
3. Build models: `dbt run`
4. Run tests: `dbt test`
5. View docs: `dbt docs generate && dbt docs serve`

## Adding / Removing Sources

- To add a new source (e.g., WooCommerce): copy an existing folder in `staging/commercial/` and adapt
- To remove an unused source (e.g., Snapchat): delete the folder — downstream models remain unaffected
- Update `sources.yml` and `marketing_channel_taxonomy.csv` as needed

## Support

For questions or customisations, contact Donovan (contractor).

Happy analysing! 🚀