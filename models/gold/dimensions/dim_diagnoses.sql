SELECT
    {{ dbt_utils.generate_surrogate_key(['diagnosis_id']) }} AS diagnosis_key,
    diagnosis_id,
    diagnosis_code,
    diagnosis_name,
    icd10_code,
    is_primary
FROM {{ ref('silver_diagnoses') }}
