WITH
cte1 AS
    (SELECT 
        i.order_id,
        SUM(i.quantity) AS total_count,
        SUM(i.quantity * p.unit_price) AS items_total
    FROM {{ ref('stg_order_items')  }} i
    JOIN {{ ref('stg_products') }} p
    ON i.product_id = p.product_id),
cte2 AS
    (SELECT 
        order_id,
        SUM(amount) AS paid_total
    FROM {{ ref('stg_payments')  }}
    GROUP BY order_id)
SELECT cte1.*, COALESCE(cte2.paid_total, 0) paid_total
FROM cte1
JOIN cte2 
ON cte1.order_id = cte2.order_id