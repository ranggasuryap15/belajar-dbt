SELECT
    payment_id,
    amount
FROM {{ ref('silver_payments') }}
WHERE amount < 0