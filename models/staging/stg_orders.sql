with source as (
    select * from {{ source('raw_ecommerce', 'orders') }}
),

renamed as (
    select
        cast(order_id as string) as order_id,
        cast(customer_id as string) as customer_id,
        cast(order_status as string) as order_status,
        timestamp(order_purchase_timestamp) as purchased_at,
        timestamp(order_approved_at) as approved_at,
        timestamp(order_delivered_carrier_date) as shipped_at,
        timestamp(order_delivered_customer_date) as delivered_at,
        timestamp(order_estimated_delivery_date) as estimated_delivery_at
    from source
)

select * from renamed