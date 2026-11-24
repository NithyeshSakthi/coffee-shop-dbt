SELECT 
    f.ordered_at::DATE AS sales_date, 
    d.store_name AS store_name, p.category AS category,
    COUNT(DISTINCT f.order_id) AS orders,
    SUM(f.quantity) AS units,
    SUM(f.line_amount) AS revenue
FROM {{ ref ("fct_order_items") }} f
JOIN {{ ref ("dim_stores")}} d
    ON f.store_key = d.store_key 
JOIN {{ ref ("dim_products")}} p
    ON f.product_id = p.product_id
GROUP BY 1,2,3
ORDER BY 1 DESC