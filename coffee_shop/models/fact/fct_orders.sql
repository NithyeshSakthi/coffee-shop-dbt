SELECT 
    o.order_id, 
    o.customer_id,
    s.store_key,
    o.ordered_at,
    o.ordered_at::date AS order_date,
    o.order_status,
    t.total_count,
    t.items_total,
    t.paid_total,
    round(t.paid_total-t.items_total, 2)  AS payment_gap,
    abs(t.items_total - t.paid_total) > 0.01 as is_payment_mismatch
FROM {{ref("stg_orders")}} o
LEFT JOIN {{ ref('stg_stores') }} s
ON s.store_name = o.store_name
LEFT JOIN {{ ref('int_order_totals') }} t
ON t.order_id = o.order_id