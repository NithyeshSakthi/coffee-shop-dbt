WITH
raword AS(
    SELECT * FROM {{ source('raw', 'raw_orders') }}  ),
stag AS
    (SELECT 
        order_id,
        customer_id,
        order_ts ::timestamp_ntz ordered_at, --- no time zone
        LOWER(TRIM(status)) order_status,
        trim(store) store_name
    FROM raword)
SELECT * FROM stag
QUALIFY ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY ordered_at DESC) =1