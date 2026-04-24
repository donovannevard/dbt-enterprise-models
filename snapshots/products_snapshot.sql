{% snapshot products_snapshot %}

{{ config(
    unique_key=['date', 'id']
    strategy='timestamp',
    updated_at='_fivetran_synced',
    invalidate_hard_deletes=True
) }}

SELECT
    CAST(date AS DATE) AS "date",
    id,
    price
FROM {{ ref('agg_products') }}

{% endsnapshot %}