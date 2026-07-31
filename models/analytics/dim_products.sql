SELECT
    id,
    name,
    category,
    price,
    currency_code,
    currency_symbol,
    decimal_places,
    created_at
FROM {{ ref('int_product__enriched') }}
