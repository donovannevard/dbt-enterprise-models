WITH
    source_data AS (
        SELECT
            session_id,
            source,
            medium,
            campaign
        FROM {{ ref('stg_google_analytics__sessions') }}
    ),
    channel_lookup AS (
        SELECT
            *
        FROM {{ ref('marketing_channel_taxonomy') }}
    ),
    -- marketing_channel_taxonomy has no source/medium/priority columns, only a single
    -- campaign_name_pattern regex per channel — match it against source/medium/campaign
    -- combined, and prefer the most specific (longest) pattern when more than one matches.
    classified AS (
        SELECT
            s.*,
            COALESCE(cm.channel, 'Other') AS channel_grouping,
            cm.subchannel,
            ROW_NUMBER() OVER (
                PARTITION BY s.session_id
                ORDER BY LENGTH(cm.campaign_name_pattern) DESC NULLS LAST
            ) AS rn
        FROM source_data AS s
        LEFT JOIN channel_lookup AS cm
            ON CONCAT_WS('-', s.source, s.medium, s.campaign) RLIKE '.*' || cm.campaign_name_pattern || '.*'
    )
SELECT
    session_id,
    source,
    medium,
    campaign,
    channel_grouping,
    subchannel
FROM classified
WHERE rn = 1  -- take the most specific match
