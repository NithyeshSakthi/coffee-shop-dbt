SELECT 
    payment_id,
    order_id,
    lower(trim(payment_method)) as payment_method,
    amount_cents,
    Round(amount_cents/100, 2) as amount,
    created_at,
FROM {{ source ('raw', 'raw_payments')  }}