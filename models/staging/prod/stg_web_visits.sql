WITH
    source_data AS (
        SELECT * FROM {{ source('extract', 'prod_web_visits') }}
    ),
    renamed AS (
        SELECT
            CAST(id AS INTEGER) AS id,
            CAST(visited_at AS TIMESTAMP) AS visited_at,
            TRY_CAST(customer_id AS INTEGER) AS customer_id,
            NULLIF(gclid, '') AS gclid,
            landing_page,
            device_category,
            _fivetran_synced AS _loaded_at
        FROM source_data
    )
SELECT * FROM renamed
