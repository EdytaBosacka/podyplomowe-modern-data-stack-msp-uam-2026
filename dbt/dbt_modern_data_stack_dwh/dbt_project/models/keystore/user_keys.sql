{{
    config(
        materialized='incremental',
        unique_key='customer_id'
    )
}}

SELECT
    customer_id,
    -- Generujemy profesjonalny zestaw kluczy AEAD
    TO_HEX(KEYS.NEW_KEYSET('AEAD_AES_GCM_256')) as encryption_key
FROM {{ source('gcs_raw', 'ext_customers') }}

{% if is_incremental() %}
  WHERE customer_id NOT IN (SELECT customer_id FROM {{ this }})
{% endif %}