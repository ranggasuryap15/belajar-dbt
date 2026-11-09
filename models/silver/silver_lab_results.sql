
WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'lab_results') }}
    WHERE lab_result_id IS NOT NULL
),

cleaned AS (
    SELECT
        TRIM(lab_result_id) AS lab_result_id,
        TRIM(visit_id) AS visit_id,
        UPPER(NULLIF(TRIM(test_code), '')) AS test_code,
        INITCAP(NULLIF(TRIM(test_name), '')) AS test_name,
        SAFE_CAST(result_value AS FLOAT64) AS result_value,
        NULLIF(TRIM(unit), '') AS unit,
        SAFE_CAST(reference_min AS FLOAT64) AS reference_min,
        SAFE_CAST(reference_max AS FLOAT64) AS reference_max,
        UPPER(NULLIF(TRIM(result_status), '')) AS result_status,
        result_datetime
    FROM source_data
)

SELECT *
FROM cleaned
