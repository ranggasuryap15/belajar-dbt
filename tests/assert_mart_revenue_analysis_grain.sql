SELECT
    hospital_key,
    year,
    month,
    payment_method,
    payment_status,
    COUNT(*) AS row_count
FROM {{ ref('mart_revenue_analysis') }}
GROUP BY
    hospital_key,
    year,
    month,
    payment_method,
    payment_status
HAVING COUNT(*) > 1