WITH
    source_data AS (
        SELECT
            session_id,
            source,
            medium,
            campaign
        FROM {{ ref('stg_ga4__sessions') }}
    ),
    channel_lookup AS (
        SELECT
            *
        FROM {{ ref('marketing_channel_taxonomy') }}
    ),
    classified AS (
        SELECT
            s.*,
            COALESCE(cm.channel_grouping, 'Other') AS channel_grouping,
            ROW_NUMBER() OVER (
                PARTITION BY s.session_id
                ORDER BY cm.priority ASC  -- most specific first
            ) AS rn
        FROM "source_data" AS s
        LEFT JOIN "channel_lookup" AS cm
            ON (s.source ILIKE cm.source OR cm.source IS NULL OR cm.source ~ s.source)  -- regex support if needed
            AND (s.medium ILIKE cm.medium OR cm.medium IS NULL)
            AND (s.campaign ILIKE '%' || cm.campaign_name_pattern || '%' OR cm.campaign_name_pattern IS NULL OR cm.campaign_name_pattern = '')
    )
SELECT
    session_id,
    source,
    medium,
    campaign,
    channel_grouping
FROM classified
WHERE rn = 1  -- take the highest-priority match