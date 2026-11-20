WITH raw_payments AS(
    SELECT * FROM COFFEE_SHOP.RAW.RAW_PAYMENTS
)
SELECT 
    payment_id,
    order_id,
    payment_method,
    amount_cents AS payment_amount,
    created_at AS payment_timestamp
FROM raw_payments