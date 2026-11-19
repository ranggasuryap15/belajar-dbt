WITH hospital_monthly_visits AS (

    SELECT
        hospital_key,
        hospital_name,
        city,
        year,
        month,
        month_name,
        total_visits

    FROM {{ ref('mart_hospital_monthly_trend') }}

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'hospital_key',
            'year',
            'month'
        ]) }} AS hospital_moving_average_key,

        hospital_key,
        hospital_name,
        city,
        year,
        month,
        month_name,
        total_visits,

        AVG(total_visits) OVER (
            PARTITION BY hospital_key
            ORDER BY year, month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS moving_average_3_months

    FROM hospital_monthly_visits

)

SELECT
    hospital_moving_average_key,
    hospital_key,
    hospital_name,
    city,
    year,
    month,
    month_name,
    total_visits,
    moving_average_3_months

FROM final