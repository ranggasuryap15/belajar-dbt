WITH date_range AS (

    SELECT
        MIN(d.full_date) AS min_date,
        MAX(d.full_date) AS max_date

    FROM {{ ref('fact_visits') }} v

    JOIN {{ ref('dim_date') }} d
        ON v.visit_date_key = d.date_key

),

calendar_months AS (

    SELECT DISTINCT
        d.year,
        d.month,
        d.month_name

    FROM {{ ref('dim_date') }} d

    CROSS JOIN date_range r

    WHERE d.full_date BETWEEN r.min_date AND r.max_date

),

hospitals AS (

    SELECT hospital_key

    FROM {{ ref('dim_hospitals') }}

),

hospital_month_spine AS (

    SELECT
        h.hospital_key,
        c.year,
        c.month,
        c.month_name

    FROM hospitals h

    CROSS JOIN calendar_months c

),

monthly_visits AS (

    SELECT
        v.hospital_key,
        d.year,
        d.month,

        COUNT(v.visit_id) AS total_visits

    FROM {{ ref('fact_visits') }} v

    JOIN {{ ref('dim_date') }} d
        ON v.visit_date_key = d.date_key

    GROUP BY
        v.hospital_key,
        d.year,
        d.month

),

filled_months AS (

    SELECT
        s.hospital_key,
        s.year,
        s.month,
        s.month_name,

        COALESCE(mv.total_visits, 0) AS total_visits

    FROM hospital_month_spine s

    LEFT JOIN monthly_visits mv
        ON
            s.hospital_key = mv.hospital_key
            AND s.year = mv.year
            AND s.month = mv.month

),

with_window_metrics AS (

    SELECT
        hospital_key,
        year,
        month,
        month_name,
        total_visits,

        LAG(total_visits) OVER (
            PARTITION BY hospital_key
            ORDER BY year, month
        ) AS previous_month_visits,

        AVG(total_visits) OVER (
            PARTITION BY hospital_key
            ORDER BY year, month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS moving_average_3_months,

        LAG(total_visits, 1) OVER (
            PARTITION BY hospital_key, month
            ORDER BY year
        ) AS previous_year_visits

    FROM filled_months

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'hospital_key',
            'year',
            'month'
        ]) }} AS hospital_monthly_trend_key,

        hospital_key,
        year,
        month,
        month_name,
        total_visits,
        previous_month_visits,
        moving_average_3_months,
        previous_year_visits,

        total_visits - previous_month_visits AS visit_change,

        SAFE_DIVIDE(
            total_visits - previous_month_visits,
            previous_month_visits
        ) * 100 AS visit_change_percentage

    FROM with_window_metrics

)

SELECT
    f.hospital_monthly_trend_key,
    f.hospital_key,
    h.hospital_name,
    h.city,
    f.year,
    f.month,
    f.month_name,
    f.total_visits,
    f.previous_month_visits,
    f.moving_average_3_months,
    f.previous_year_visits,
    f.visit_change,
    f.visit_change_percentage

FROM final f

JOIN {{ ref('dim_hospitals') }} h
    ON f.hospital_key = h.hospital_key
