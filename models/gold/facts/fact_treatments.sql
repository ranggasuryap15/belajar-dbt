WITH treatments AS (
    SELECT * FROM {{ ref('silver_treatments') }}
),

final AS (
    SELECT
        t.treatment_id,
        t.visit_id,

        -- Dimension keys
        v.patient_key,
        v.doctor_key,
        v.hospital_key,
        dt.date_key AS treatment_date_key,

        -- Treatment attributes
        t.treatment_code,
        t.treatment_name,
        t.category,
        t.performed_at,

        -- Measures
        t.quantity,
        t.unit_price,
        t.total_price,
        1 AS treatment_count

    FROM treatments t

    LEFT JOIN {{ ref('fact_visits') }} v
        ON t.visit_id = v.visit_id

    LEFT JOIN {{ ref('dim_date') }} dt
        ON DATE(t.performed_at) = dt.full_date
)

SELECT * FROM final
