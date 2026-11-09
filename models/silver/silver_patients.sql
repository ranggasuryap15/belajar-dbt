SELECT *
FROM {{ source('healthcare', 'patients') }}
WHERE patient_id IS NOT NULL
