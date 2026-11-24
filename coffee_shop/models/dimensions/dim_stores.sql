SELECT 
    store_key,
    store_name,
    city,
    opened_date
FROM {{ ref('stg_stores') }} 