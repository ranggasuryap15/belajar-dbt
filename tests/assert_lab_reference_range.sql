SELECT
    lab_result_id,
    reference_min,
    reference_max
FROM {{ ref('silver_lab_results') }}
WHERE
    reference_min IS NOT NULL
    AND reference_max IS NOT NULL
    AND reference_min > reference_max