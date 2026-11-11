WITH date_spine AS (
    SELECT date_day
    FROM UNNEST(
        GENERATE_DATE_ARRAY(
            DATE '2020-01-01',
            DATE '2030-12-31',
            INTERVAL 1 DAY
        )
    ) AS date_day
),

final AS (
    SELECT
        CAST(FORMAT_DATE('%Y%m%d', date_day) AS INT64) AS date_key,

        date_day AS full_date,

        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(MONTH FROM date_day) AS month,
        FORMAT_DATE('%B', date_day) AS month_name,
        FORMAT_DATE('%b', date_day) AS month_short,

        EXTRACT(DAY FROM date_day) AS day,
        FORMAT_DATE('%A', date_day) AS day_name,
        FORMAT_DATE('%a', date_day) AS day_short,

        EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,

        CASE
            WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7)
                THEN TRUE
            ELSE FALSE
        END AS is_weekend,

        DATE_TRUNC(date_day, MONTH) AS first_day_of_month,
        LAST_DAY(date_day, MONTH) AS last_day_of_month

    FROM date_spine
)

SELECT *
FROM final
