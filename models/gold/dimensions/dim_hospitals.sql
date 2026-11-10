SELECT
    hospital_id,
    hospital_name,
    city,
    hospital_type,
    bed_capacity,
    is_active
FROM {{ ref('silver_hospitals') }}
