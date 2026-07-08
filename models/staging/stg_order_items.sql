with source as (
    select * from {{ source('raw_ecommerce', 'order_items') }}
),

renamed as (
    select
        cast(order_id as string) as order_id,
        cast(order_item_id as int64) as order_item_sequence,
        cast(product_id as string) as product_id,
        cast(seller_id as string) as seller_id,
        timestamp(shipping_limit_date) as shipping_limit_at,
        cast(price as numeric) as price,
        cast(freight_value as numeric) as freight_value
    from source
)

select * from renamed