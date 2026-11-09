WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'payments') }}
    WHERE payment_id IS NOT NULL
),

cleaned AS (
    SELECT
        TRIM(payment_id) AS payment_id,
        TRIM(visit_id) AS visit_id,
        payment_datetime,
        SAFE_CAST(amount AS NUMERIC) AS amount,
        UPPER(NULLIF(TRIM(payment_method), '')) AS payment_method,
        UPPER(NULLIF(TRIM(payment_status), '')) AS payment_status
    FROM source_data
)

SELECT *
FROM cleaned