{{ config(materialized = 'table') }}

WITH
    date_spine AS (
        {{ dbt_utils.date_spine(
            datepart = "day",
            start_date = "CAST('2000-01-01' AS DATE)",  -- Adjust to earliest data if needed
            end_date = "DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '10 year'"  -- Auto-extends into future
        ) }}
    )
SELECT
    CAST(date_day AS DATE) AS "date",

    -- Basic attributes
    EXTRACT(YEAR FROM date_day) AS "year",
    EXTRACT(QUARTER FROM date_day) AS "quarter",
    EXTRACT(MONTH FROM date_day) AS "month_number",
    TO_CHAR(date_day, 'Month') AS "month_name",
    TO_CHAR(date_day, 'Mon') AS "month_short",
    EXTRACT(DAY FROM date_day) AS "day_of_month",

    -- Week attributes (ISO standard)
    EXTRACT(WEEK FROM date_day) AS "week_number",
    EXTRACT(DOW FROM date_day) AS "day_of_week_number",  -- 0 = Sunday, 6 = Saturday
    TO_CHAR(date_day, 'Day') AS "day_of_week_name",
    TO_CHAR(date_day, 'Dy') AS "day_of_week_short",

    -- Week start/end – Monday-start week (common in UK/Europe)
    DATE_TRUNC('week', date_day) + INTERVAL '1 day' AS "week_start_date",
    DATE_TRUNC('week', date_day) + INTERVAL '7 day' AS "week_end_date",

    -- Month start/end
    DATE_TRUNC('month', date_day) AS "month_start_date",
    LAST_DAY(date_day) AS "month_end_date",

    -- Year start/end
    DATE_TRUNC('year', date_day) AS "year_start_date",
    DATE_TRUNC('year', date_day) + INTERVAL '1 year' - INTERVAL '1 day' AS "year_end_date",

    -- Flags (direct boolean expressions)
    EXTRACT(DOW FROM date_day) IN (0, 6) AS "is_weekend",
    date_day = CURRENT_DATE AS "is_today"

FROM "date_spine"
ORDER BY 1