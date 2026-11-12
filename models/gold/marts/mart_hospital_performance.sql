WITH monthly_visits AS (
    SELECT
        v.hospital_key,
        d.year,
        d.month,
        d.month_name,
        COUNT(v.visit_id) AS total_visits
    FROM {{ ref('fact_visits') }} v
    JOIN {{ ref('dim_date') }} d
        ON v.visit_date_key = d.date_key
    GROUP BY 1, 2, 3, 4
),

monthly_payments AS (
    SELECT
        v.hospital_key,
        d.year,
        d.month,
        SUM(p.amount) AS total_revenue
    FROM {{ ref('fact_payments') }} p
    JOIN {{ ref('fact_visits') }} v
        ON p.visit_id = v.visit_id
    JOIN {{ ref('dim_date') }} d
        ON p.payment_date_key = d.date_key
    GROUP BY 1, 2, 3
),

monthly_treatments AS (
    SELECT
        v.hospital_key,
        d.year,
        d.month,
        COUNT(t.treatment_id) AS total_treatments
    FROM {{ ref('fact_treatments') }} t
    JOIN {{ ref('dim_date') }} d
        ON t.treatment_date_key = d.date_key
    JOIN {{ ref('fact_visits') }} v
        ON t.visit_id = v.visit_id
    GROUP BY 1, 2, 3
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['h.hospital_key', 'mv.year', 'mv.month']) }} AS mart_hospital_performance_key,
        h.hospital_key,
        h.hospital_name,
        h.city,
        mv.year,
        mv.month,
        mv.month_name,
        COALESCE(mv.total_visits, 0) AS total_visits,
        COALESCE(mp.total_revenue, 0) AS total_revenue,
        COALESCE(mt.total_treatments, 0) AS total_treatments
    FROM {{ ref('dim_hospitals') }} h
    JOIN monthly_visits mv
        ON h.hospital_key = mv.hospital_key
    LEFT JOIN monthly_payments mp
        ON h.hospital_key = mp.hospital_key
        AND mv.year = mp.year
        AND mv.month = mp.month
    LEFT JOIN monthly_treatments mt
        ON h.hospital_key = mt.hospital_key
        AND mv.year = mt.year
        AND mv.month = mt.month
)

SELECT * FROM final