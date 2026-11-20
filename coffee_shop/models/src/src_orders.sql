WITH raw_orders AS(
    SELECT * FROM COFFEE_SHOP.RAW.RAW_ORDERS
)
SELECT 
    order_id,
    customer_id,
    ORDER_TS AS order_timestamp,
    status AS order_status,
    STORE AS order_branch 
FROM raw_orders