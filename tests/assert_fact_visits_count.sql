SELECT *
FROM {{ ref('fact_visits') }}
WHERE visit_count != 1
   OR visit_count IS NULL