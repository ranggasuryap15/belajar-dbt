SELECT *
FROM {{ ref('silver_patients') }}
WHERE date_of_birth > CURRENT_DATE()