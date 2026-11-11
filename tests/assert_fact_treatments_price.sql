SELECT *
FROM {{ ref('fact_treatments') }}
WHERE
    quantity IS NOT NULL
    AND unit_price IS NOT NULL
    AND total_price IS NOT NULL
    AND total_price != quantity * unit_price