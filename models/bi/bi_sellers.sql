with sellers as (
    select * from {{ ref('dim_sellers') }}
),

order_items as (
    select
        seller_id,
        round(avg(price), 2) as avg_item_price,
        round(avg(freight_value), 2) as avg_freight_value
    from {{ ref('stg_order_items') }}
    group by seller_id
),

orders as (
    select
        oi.seller_id,
        count(distinct o.order_id) as total_orders,
        count(distinct case when o.delivery_status = 'on_time' then o.order_id end) as on_time_orders,
        round(avg(o.delivery_delay_days), 1) as avg_delivery_delay_days
    from {{ ref('fct_orders') }} o
    left join {{ ref('stg_order_items') }} oi on o.order_id = oi.order_id
    group by oi.seller_id
),

final as (
    select
        s.seller_key,
        s.seller_id,
        s.zip_code_prefix,
        s.seller_city,
        s.seller_state,
        s.lifetime_orders,
        s.lifetime_revenue,
        s.distinct_products_sold,
        s.first_sale_at,
        s.last_sale_at,
        oi.avg_item_price,
        oi.avg_freight_value,
        o.total_orders,
        o.on_time_orders,
        round(o.on_time_orders / nullif(o.total_orders, 0), 4) as on_time_rate,
        o.avg_delivery_delay_days
    from sellers s
    left join order_items oi on s.seller_id = oi.seller_id
    left join orders o on s.seller_id = o.seller_id
)

select * from final
