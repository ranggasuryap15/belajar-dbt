WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'hospitals') }}
    WHERE hospital_id IS NOT NULL
),

deduplicated AS (
    SELECT *
    FROM source_data
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hospital_id
        ORDER BY hospital_id
    ) = 1
),

cleaned AS (
    SELECT
        TRIM(hospital_id) AS hospital_id,
        INITCAP(NULLIF(TRIM(hospital_name), '')) AS hospital_name,
        INITCAP(NULLIF(TRIM(city), '')) AS city,
        INITCAP(NULLIF(TRIM(hospital_type), '')) AS hospital_type,
        SAFE_CAST(bed_capacity AS INT64) AS bed_capacity,
        is_active
    FROM deduplicated
)

SELECT *
FROM cleaned