SELECT
    treatment_id,
    quantity,
    unit_price,
    total_price
FROM {{ ref('silver_treatments') }}
WHERE
    quantity IS NOT NULL
    AND unit_price IS NOT NULL
    AND total_price IS NOT NULL
    AND total_price != quantity * unit_price