SELECT 
    product_id, 
    product_name ,
    category,
    unit_price,
    is_active 
FROM {{ ref('stg_products')  }}