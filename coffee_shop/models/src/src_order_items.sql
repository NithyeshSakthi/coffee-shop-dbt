WITH raw_order_items AS(
    SELECT * FROM COFFEE_SHOP.RAW.RAW_ORDER_ITEMS
)
SELECT 
    order_item_id,
    order_id,
    product_id,
    quantity AS order_quantity
FROM raw_order_items