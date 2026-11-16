WITH mart_total AS (
    SELECT
        COALESCE(SUM(total_amount), 0) AS total_amount
    FROM {{ ref('mart_revenue_analysis') }}
),

source_total AS (
    SELECT
        COALESCE(SUM(amount), 0) AS total_amount
    FROM {{ ref('fact_payments') }}
)

SELECT
    mart_total.total_amount AS mart_amount,
    source_total.total_amount AS source_amount,
    mart_total.total_amount - source_total.total_amount AS difference
FROM mart_total
CROSS JOIN source_total
WHERE ABS(mart_total.total_amount - source_total.total_amount) > 0.0