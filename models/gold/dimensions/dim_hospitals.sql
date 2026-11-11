SELECT
    {{ dbt_utils.generate_surrogate_key(['hospital_id']) }} AS hospital_key,
    hospital_id,
    hospital_name,
    city,
    hospital_type,
    bed_capacity,
    is_active
FROM {{ ref('silver_hospitals') }}
