WITH payments AS (
    SELECT * FROM {{ ref('silver_payments') }}
),

final AS (
    SELECT
        p.payment_id,
        p.visit_id,

        -- Dimension keys
        v.patient_key,
        v.doctor_key,
        v.hospital_key,
        dt.date_key AS payment_date_key,

        -- Payment attributes
        p.payment_datetime,
        p.payment_method,
        p.payment_status,

        -- Measures
        p.amount,
        1 AS payment_count

    FROM payments p

    LEFT JOIN {{ ref('fact_visits') }} v
        ON p.visit_id = v.visit_id

    LEFT JOIN {{ ref('dim_date') }} dt
        ON DATE(p.payment_datetime) = dt.full_date
)

SELECT * FROM final
