SElECT 
    i.order_item_id,
    i.order_id,
    o.customer_id,
    i.product_id,
    o.store_key,
    o.ordered_at,
    i.quantity,
    i.quantity * p.unit_price as line_amount
FROM {{ ref('stg_order_items')}} i
JOIN {{ ref('fct_orders') }} o
    ON i.order_id = o.order_id
JOIN {{ ref('stg_products') }} p
    ON i.product_id = p.product_id