/*
Find the top 20 products by lifetime value
*/

SELECT
    product_id,
    SUM(gross_revenue) AS "lifetime_value"
FROM {{ ref('fct_transactions') }}
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20