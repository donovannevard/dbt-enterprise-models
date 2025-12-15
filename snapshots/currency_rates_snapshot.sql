{% snapshot currency_rates_snapshot %}

{{ config(
    target_schema='snapshots',
    unique_key='date || base_currency || target_currency',
    strategy='timestamp',
    updated_at='_fivetran_synced',
    invalidate_hard_deletes=True
) }}

SELECT
    CAST(date AS DATE) AS "date",
    base_currency,
    target_currency,
    rate AS "exchange_rate"

FROM {{ source('currency_exchange', 'exchange_rates') }}  -- Fivetran source

{% endsnapshot %}