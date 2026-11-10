
SELECT
    diagnosis_id,
    diagnosis_code,
    diagnosis_name,
    icd10_code,
    is_primary
FROM {{ ref('silver_diagnoses') }}
