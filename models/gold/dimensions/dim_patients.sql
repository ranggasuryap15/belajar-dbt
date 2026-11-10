SELECT
    patient_id,
    first_name,
    last_name,
    gender,
    date_of_birth,
    city,
    email,
    phone
FROM {{ ref('silver_patients') }}