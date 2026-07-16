with orders as (
    select
        order_id,
        order_key,
        purchased_at,
        delivery_status,
        delivery_delay_days
    from {{ ref('fct_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

sellers as (
    select * from {{ ref('dim_sellers') }}
),

final as (
    select
        oi.order_id,
        o.order_key,
        o.purchased_at,
        o.delivery_status,
        o.delivery_delay_days,
        oi.order_item_sequence,
        oi.product_id,
        p.product_key,
        p.product_category_name,
        p.product_weight_kg,
        p.product_volume_cm3,
        oi.seller_id,
        s.seller_key,
        s.zip_code_prefix as seller_zip_code_prefix,
        s.seller_city,
        s.seller_state,
        oi.price,
        oi.freight_value,
        round(oi.price + oi.freight_value, 2) as total_item_value
    from order_items oi
    left join orders o on oi.order_id = o.order_id
    left join products p on oi.product_id = p.product_id
    left join sellers s on oi.seller_id = s.seller_id
)

select * from final
