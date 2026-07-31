-- Reuses marketing_channel_taxonomy — the same seed that classifies GA4
-- sessions in int_session__marketing_channel_classification — to classify
-- ad platform campaigns into a channel, by pattern-matching the campaign
-- name directly. This only works because campaign names follow a
-- "platform + taxonomy keyword" convention (see the comment in
-- scripts/generate_example_seeds.py); a client without that convention
-- already in place needs an explicit campaign_id -> channel mapping seed
-- instead.
WITH
    campaigns AS (
        SELECT DISTINCT platform, campaign_id, campaign_name
        FROM {{ ref('int_marketing__combined') }}
    ),
    channel_lookup AS (
        SELECT * FROM {{ ref('marketing_channel_taxonomy') }}
    ),
    classified AS (
        SELECT
            c.*,
            COALESCE(ch.channel, 'Other') AS channel_grouping,
            ch.subchannel,
            ROW_NUMBER() OVER (
                PARTITION BY c.platform, c.campaign_id
                ORDER BY LENGTH(ch.campaign_name_pattern) DESC NULLS LAST
            ) AS rn
        FROM campaigns AS c
        LEFT JOIN channel_lookup AS ch
            ON LOWER(REPLACE(c.campaign_name, ' ', '-')) RLIKE '.*' || ch.campaign_name_pattern || '.*'
    )
SELECT
    platform,
    campaign_id,
    campaign_name,
    channel_grouping,
    subchannel
FROM classified
WHERE rn = 1
