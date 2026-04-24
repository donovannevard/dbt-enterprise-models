SELECT
    *
FROM {{ source('extract', 'exchange_rates') }}