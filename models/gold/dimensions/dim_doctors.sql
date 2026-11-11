SELECT
    {{ dbt_utils.generate_surrogate_key(['doctor_id']) }} AS doctor_key,
    doctor_id,
    hospital_id,
    doctor_name,
    specialty,
    gender,
    years_experience,
    is_active
FROM {{ ref('silver_doctors') }}
