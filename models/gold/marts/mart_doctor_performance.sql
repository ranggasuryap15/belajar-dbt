WITH monthly_visits AS (
    SELECT
        v.doctor_key,
        d.year,
        d.month,
        d.month_name,
        COUNT(v.visit_id) AS total_visits
    FROM {{ ref('fact_visits') }} v
    JOIN {{ ref('dim_date') }} d
        ON v.visit_date_key = d.date_key
    GROUP BY
        v.doctor_key,
        d.year,
        d.month,
        d.month_name
),

monthly_treatments AS (
    SELECT
        t.doctor_key,
        d.year,
        d.month,
        SUM(t.treatment_count) AS total_treatments,
        SUM(t.total_price) AS total_treatment_revenue
    FROM {{ ref('fact_treatments') }} t
    JOIN {{ ref('dim_date') }} d
        ON t.treatment_date_key = d.date_key
    GROUP BY
        t.doctor_key,
        d.year,
        d.month
),

monthly_labs AS (
    SELECT
        l.doctor_key,
        d.year,
        d.month,
        COUNT(l.lab_result_id) AS total_lab_tests
    FROM {{ ref('fact_lab_results') }} l
    JOIN {{ ref('dim_date') }} d
        ON l.result_date_key = d.date_key
    GROUP BY
        l.doctor_key,
        d.year,
        d.month
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'mv.doctor_key',
        'mv.year',
        'mv.month'
    ]) }} AS mart_doctor_performance_key,
    mv.doctor_key,
    doc.doctor_name,
    doc.specialty,
    mv.year,
    mv.month,
    mv.month_name,
    mv.total_visits,
    COALESCE(mt.total_treatments, 0) AS total_treatments,
    COALESCE(mt.total_treatment_revenue, 0) AS total_treatment_revenue,
    COALESCE(ml.total_lab_tests, 0) AS total_lab_tests    
FROM monthly_visits mv
JOIN {{ ref('dim_doctors') }} doc
    ON mv.doctor_key = doc.doctor_key
LEFT JOIN monthly_treatments mt
    ON mv.doctor_key = mt.doctor_key
    AND mv.year = mt.year
    AND mv.month = mt.month
LEFT JOIN monthly_labs ml
    ON mv.doctor_key = ml.doctor_key
    AND mv.year = ml.year
    AND mv.month = ml.month