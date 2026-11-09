WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'visits') }}
    WHERE visit_id IS NOT NULL
),

deduplicated AS (
    SELECT *
    FROM source_data
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY visit_id
        ORDER BY created_at DESC
    ) = 1
),

cleaned AS (
    SELECT
        TRIM(visit_id) AS visit_id,
        TRIM(patient_id) AS patient_id,
        TRIM(hospital_id) AS hospital_id,
        TRIM(doctor_id) AS doctor_id,
        SAFE_CAST(visit_datetime AS TIMESTAMP) AS visit_datetime,
        INITCAP(NULLIF(TRIM(visit_type), '')) AS visit_type,
        INITCAP(NULLIF(TRIM(status), '')) AS status,
        INITCAP(NULLIF(TRIM(chief_complaint), '')) AS chief_complaint,
        created_at
    FROM deduplicated
)

SELECT *
FROM cleaned
