SELECT
    o.order_date,
    o.amount_usd,
    o.amount_local,
    o.currency,
    COALESCE(r."exchange_rate", 1) AS "exchange_rate_to_gbp",  -- fallback to 1 if same currency
    o.amount_local * COALESCE(r."exchange_rate", 1) AS "amount_gbp"

FROM {{ ref('fct_orders') }} o
LEFT JOIN {{ ref('currency_rates_snapshot') }} r
  ON o.order_date = r."date"
  AND o.currency = r.target_currency
  AND r.base_currency = 'GBP'