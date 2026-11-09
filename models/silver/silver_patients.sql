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
)

SELECT * EXCEPT (row_num)
FROM ranked_data
WHERE row_num = 1