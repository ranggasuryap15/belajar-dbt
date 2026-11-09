
WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'doctors') }}
    WHERE doctor_id IS NOT NULL
),

deduplicated AS (
    SELECT *
    FROM source_data
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY doctor_id
        ORDER BY doctor_id
    ) = 1
),

cleaned AS (
    SELECT
        TRIM(doctor_id) AS doctor_id,
        TRIM(hospital_id) AS hospital_id,
        INITCAP(NULLIF(TRIM(doctor_name), '')) AS doctor_name,
        INITCAP(NULLIF(TRIM(specialty), '')) AS specialty,
        UPPER(NULLIF(TRIM(gender), '')) AS gender,
        SAFE_CAST(years_experience AS INT64) AS years_experience,
        is_active
    FROM deduplicated
)

SELECT *
FROM cleaned