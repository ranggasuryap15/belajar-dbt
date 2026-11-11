
WITH lab_results AS (
    SELECT *
    FROM {{ ref('silver_lab_results') }}
),

final AS (
    SELECT
        l.lab_result_id,
        l.visit_id,

        -- Dimension keys
        v.patient_key,
        v.doctor_key,
        v.hospital_key,

        -- Laboratory attributes
        l.test_code,
        l.test_name,
        l.result_status,
        l.result_datetime,

        -- Measures
        l.result_value,
        l.reference_min,
        l.reference_max,
        1 AS lab_test_count

    FROM lab_results l

    LEFT JOIN {{ ref('fact_visits') }} v
        ON l.visit_id = v.visit_id
)

SELECT *
FROM final
