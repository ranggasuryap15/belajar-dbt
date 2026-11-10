SELECT
    doctor_id,
    hospital_id,
    doctor_name,
    specialty,
    gender,
    years_experience,
    is_active
FROM {{ ref('silver_doctors') }}
