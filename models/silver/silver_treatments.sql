WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'treatments') }}
    WHERE treatment_id IS NOT NULL
),

cleaned AS (
    SELECT
        TRIM(treatment_id) AS treatment_id,
        TRIM(visit_id) AS visit_id,
        UPPER(NULLIF(TRIM(treatment_code), '')) AS treatment_code,
        INITCAP(NULLIF(TRIM(treatment_name), '')) AS treatment_name,
        INITCAP(NULLIF(TRIM(category), '')) AS category,
        SAFE_CAST(quantity AS INT64) AS quantity,
        SAFE_CAST(unit_price AS NUMERIC) AS unit_price,
        SAFE_CAST(total_price AS NUMERIC) AS total_price,
        performed_at
    FROM source_data
)

SELECT *
FROM cleaned
