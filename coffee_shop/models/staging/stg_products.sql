SELECT 
    DISTINCT product_id AS product_id, 
    INITCAP(TRIM(product_name)) AS product_name ,
    lower(TRIM(category)) AS category,
    unit_price,
    is_active::boolean AS is_active  ---is_act as boolean
FROM {{ source('raw','raw_products')  }}