WITH mart_revenue AS (
    SELECT
        hospital_key,
        year,
        month,
        SUM(total_amount) AS mart_amount
    FROM {{ ref('mart_revenue_analysis') }}
    GROUP BY
        hospital_key,
        year,
        month
),

source_revenue AS (
    SELECT
        p.hospital_key,
        d.year,
        d.month,
        SUM(p.amount) AS source_amount
    FROM {{ ref('fact_payments') }} p
    JOIN {{ ref('dim_date') }} d
        ON p.payment_date_key = d.date_key
    GROUP BY
        p.hospital_key,
        d.year,
        d.month
),

comparison AS (
    SELECT
        COALESCE(m.hospital_key, s.hospital_key) AS hospital_key,
        COALESCE(m.year, s.year) AS year,
        COALESCE(m.month, s.month) AS month,
        COALESCE(m.mart_amount, 0) AS mart_amount,
        COALESCE(s.source_amount, 0) AS source_amount
    FROM mart_revenue m
    FULL OUTER JOIN source_revenue s
        ON m.hospital_key = s.hospital_key
        AND m.year = s.year
        AND m.month = s.month
)

SELECT
    hospital_key,
    year,
    month,
    mart_amount,
    source_amount,
    mart_amount - source_amount AS difference
FROM comparison
WHERE ABS(mart_amount - source_amount) > 0.01