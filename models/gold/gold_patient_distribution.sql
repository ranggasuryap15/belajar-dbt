
{{ config(materialized='table') }}

SELECT
    city,
    total_patients,

    ROUND(
        total_patients * 100.0
        / SUM(total_patients) OVER (),
        2
    ) AS percentage_of_patients

FROM {{ ref('gold_patient_summary') }}
