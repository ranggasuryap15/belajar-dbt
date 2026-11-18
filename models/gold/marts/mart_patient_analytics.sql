WITH patient_visits AS (

    SELECT
        patient_key,

        COUNT(visit_id) AS total_visits,

        MIN(visit_datetime) AS first_visit_datetime,

        MAX(visit_datetime) AS last_visit_datetime

    FROM {{ ref('fact_visits') }}

    GROUP BY
        patient_key

),

patient_enriched AS (

    SELECT
        p.patient_key,
        p.patient_id,
        p.first_name,
        p.last_name,
        p.gender,
        p.date_of_birth,
        p.city,

        DATE_DIFF(
            CURRENT_DATE(),
            p.date_of_birth,
            YEAR
        )
        -
        IF(
            FORMAT_DATE('%m%d', CURRENT_DATE())
            <
            FORMAT_DATE('%m%d', p.date_of_birth),
            1,
            0
        ) AS age,

        COALESCE(pv.total_visits, 0) AS total_visits,

        pv.first_visit_datetime,

        pv.last_visit_datetime

    FROM {{ ref('dim_patients') }} p

    LEFT JOIN patient_visits pv
        ON p.patient_key = pv.patient_key

),

final AS (

    SELECT
        patient_key,
        patient_id,
        first_name,
        last_name,
        gender,
        date_of_birth,
        city,
        age,

        CASE
            WHEN age IS NULL THEN 'UNKNOWN'
            WHEN age < 18 THEN 'UNDER_18'
            WHEN age BETWEEN 18 AND 35 THEN '18_35'
            WHEN age BETWEEN 36 AND 50 THEN '36_50'
            WHEN age BETWEEN 51 AND 65 THEN '51_65'
            ELSE 'OVER_65'
        END AS age_group,

        total_visits,
        first_visit_datetime,
        last_visit_datetime,

        CASE
            WHEN total_visits > 0 THEN TRUE
            ELSE FALSE
        END AS is_active

    FROM patient_enriched

)

SELECT *
FROM final