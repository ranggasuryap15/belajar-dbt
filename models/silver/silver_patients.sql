WITH source_data AS (
    SELECT *
    FROM {{ source('healthcare', 'patients') }}
    WHERE patient_id IS NOT NULL
),

ranked_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY patient_id
            ORDER BY updated_at DESC, created_at DESC
        ) AS row_num
    FROM source_data
),

deduplicated AS (
    SELECT * EXCEPT (row_num)
    FROM ranked_data
    WHERE row_num = 1
),

cleaned AS (
    SELECT
        TRIM(patient_id) AS patient_id,

        INITCAP(NULLIF(TRIM(first_name), '')) AS first_name,
        INITCAP(NULLIF(TRIM(last_name), '')) AS last_name,

        CASE
            WHEN UPPER(TRIM(gender)) IN ('M', 'MALE')
                THEN 'MALE'
            WHEN UPPER(TRIM(gender)) IN ('F', 'FEMALE')
                THEN 'FEMALE'
            WHEN gender IS NULL OR TRIM(gender) = ''
                THEN NULL
            ELSE 'UNKNOWN'
        END AS gender,

        CASE
            WHEN date_of_birth IS NULL
                THEN NULL
            WHEN date_of_birth > CURRENT_DATE()
                THEN NULL
            WHEN DATE_DIFF(
                CURRENT_DATE(),
                date_of_birth,
                YEAR
            ) > 120
                THEN NULL
            ELSE date_of_birth
        END AS date_of_birth,

        INITCAP(NULLIF(TRIM(city), '')) AS city,

        LOWER(NULLIF(TRIM(email), '')) AS email,
        NULLIF(TRIM(phone), '') AS phone,

        created_at,
        updated_at

    FROM deduplicated
)

SELECT *
FROM cleaned
