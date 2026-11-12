WITH visits AS (
    SELECT *
    FROM {{ ref('silver_visits') }}
),

final AS (
    SELECT
        v.visit_id,

        -- Surrogate keys from dimensions
        p.patient_key,
        d.doctor_key,
        h.hospital_key,
        dt.date_key AS visit_date_key,

        -- Visit attributes
        v.visit_datetime,
        v.visit_type,
        v.status,
        v.chief_complaint,

        -- Measures
        1 AS visit_count

    FROM visits v

    LEFT JOIN {{ ref('dim_patients') }} p
        ON v.patient_id = p.patient_id

    LEFT JOIN {{ ref('dim_doctors') }} d
        ON v.doctor_id = d.doctor_id

    LEFT JOIN {{ ref('dim_hospitals') }} h
        ON v.hospital_id = h.hospital_id

    LEFT JOIN {{ ref('dim_date') }} dt
        ON DATE(v.visit_datetime) = dt.full_date
)

SELECT *
FROM final
