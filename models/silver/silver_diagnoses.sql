
WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'diagnoses') }}
    WHERE diagnosis_id IS NOT NULL
),

cleaned AS (
    SELECT
        TRIM(diagnosis_id) AS diagnosis_id,
        TRIM(visit_id) AS visit_id,
        UPPER(NULLIF(TRIM(diagnosis_code), '')) AS diagnosis_code,
        INITCAP(NULLIF(TRIM(diagnosis_name), '')) AS diagnosis_name,
        UPPER(NULLIF(TRIM(icd10_code), '')) AS icd10_code,
        is_primary
    FROM source_data
)

SELECT *
FROM cleaned
