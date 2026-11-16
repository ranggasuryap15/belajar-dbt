WITH payments_enriched AS (
    SELECT
        p.payment_id,
        p.amount,
        p.payment_method,
        p.payment_status,
        v.hospital_key,
        d.year,
        d.month,
        d.month_name
    FROM {{ ref('fact_payments') }} p
    JOIN {{ ref('fact_visits') }} v
        ON p.visit_id = v.visit_id
    JOIN {{ ref('dim_date') }} d
        ON p.payment_date_key = d.date_key
),

aggregated AS (
    SELECT
        pe.hospital_key,
        pe.year,
        pe.month,
        pe.month_name,
        pe.payment_method,
        pe.payment_status,
        COUNT(pe.payment_id) AS total_transactions,
        SUM(pe.amount) AS total_amount
    FROM payments_enriched pe
    GROUP BY 1, 2, 3, 4, 5, 6
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'a.hospital_key',
            'a.year',
            'a.month',
            'a.payment_method',
            'a.payment_status'
        ]) }} AS mart_revenue_analysis_key,
        a.hospital_key,
        h.hospital_name,
        h.city,
        h.hospital_type,
        a.year,
        a.month,
        a.month_name,
        a.payment_method,
        a.payment_status,
        a.total_transactions,
        a.total_amount
    FROM aggregated a
    JOIN {{ ref('dim_hospitals') }} h
        ON a.hospital_key = h.hospital_key
)

SELECT * FROM final