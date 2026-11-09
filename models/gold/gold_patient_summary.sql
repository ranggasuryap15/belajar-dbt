
{{ config(materialized='table') }}

SELECT
    city,
    COUNT(*) AS total_patients

FROM {{ ref('silver_patients') }}

GROUP BY
    city
