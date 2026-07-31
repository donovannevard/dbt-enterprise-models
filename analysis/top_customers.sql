/*
Find the top 10 customers by lifetime value
*/

SELECT
    customer_id,
    SUM(gross_revenue) AS "lifetime_value"
FROM {{ ref('fct_transactions') }}
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10