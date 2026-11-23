SELECT 
    order_item_id::NUMBER AS order_item_id,
    order_id::NUMBER AS order_id,
    product_id::NUMBER as product_id,
    quantity::INT as quantity
FROM {{ source('raw','raw_order_items')  }}
