# dbt-enterprise-models

A production-ready, contractor-optimized dbt project for modern marketing, e-commerce, and operational analytics.

This template is designed to get clients up and running in **hours**, not weeks, with clean, tested, documented models covering the most common data sources in 2025.

## Features

- **Comprehensive marketing ads coverage**  
  Pre-built staging models for Facebook/Meta Ads, Google Ads, TikTok Ads, Snapchat Ads, Pinterest Ads, X/Twitter Ads, LinkedIn Ads, Microsoft Ads, Reddit Ads, Amazon Ads, and more.

- **Commercial & operational sources**  
  Ready for Shopify, Stripe, Amazon Seller, eBay, QuickBooks, HubSpot, Salesforce, Klaviyo, Google Analytics 4, and custom databases (`proddb/`).

- **Rich reference data (seeds)**  
  - `country_codes` (all countries with ISO codes, currency, primary timezone)  
  - `currency_info` (symbols, decimal places)  
  - `time_zones` (24 core time zones with UTC offset and DST support)  
  - `bank_holidays` (UK & Ireland 2015–2030)  
  - `uk_outward_postcodes` (all UK postcode districts with town, county, lat/long)  
  - `marketing_channel_taxonomy` (configurable channel groupings with priority)

- **Core analytics layer**  
  - `dim_date` — auto-generated date dimension (2015–2030+)  
  - Clean separation: `staging` → `intermediate` → `analytics`  
  - BI-ready tables: `dim_*` (dimensions), `fct_*` (facts), `agg_*` (aggregates)

- **Data quality out of the box**  
  Generic tests for uniqueness, nulls, positive values, ranges, and status-based checks.

- **Best practices built in**  
  - Views for staging (fast iteration)  
  - Tables/incremental for facts (performance)  
  - Schema routing by folder (`staging_commercial`, `staging_marketing`, `staging_proddb`, `analytics`)  
  - Leverages `dbt_utils` and `fivetran_utils`

## Project Structure

```
models/
├── staging/
│   ├── commercial/      # Shopify, Stripe, Amazon, eBay, etc.
│   ├── marketing/       # All paid advertising platforms
│   └── proddb/          # Custom database/website
├── intermediate/        # Business logic and joins
└── analytics/           # Final BI-ready models (dim_, fct_, agg_*)
seeds/                   # Reference data
snapshots/               # SCD Type 2 (add as needed)
tests/                   # Generic + model-specific tests
macros/                  # Custom macros (start empty, add per client)
analysis/                # Ad-hoc queries (ignored in production runs)
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

3. **Load reference data**
    ```bash
    dbt seed
    ```

4. **Connect to your warehouse**
    - Copy `profiles.yml.example` to `~/profiles.yaml` and fill in credentials (from your Terraform outputs).

5. **Run the project**
    ```bash
    dbt run # Build all models
    dbt test # Run data quality tests
    dbt docs generate && dbt docs serve # View lineage & docs
    ```

## Customising for Your Sources
- Add a new source (e.g., WooCommerce): copy an existing folder in staging/commercial/ and adapt the models.
- Remove an unused source (e.g., Snapchat): simply delete the folder — downstream models remain unaffected.
- Update channel groupings: edit seeds/marketing_channel_taxonomy.csv and re-run dbt seed.

## Deployment
- Use dbt Cloud for scheduling, CI/CD, and team collaboration (recommended for most clients).
- Or run locally/on a server with GitHub Actions or Airflow.

## Support & Customisation
- Built and maintained by Donovan — freelance data contractor.
- For extensions (custom sources, advanced metrics, dbt Cloud setup, monitoring), get in touch.

## Built for speed by a contractor who hates slow setups. 🚀