SELECT *
FROM {{ ref('fact_payments') }}
WHERE amount < 0