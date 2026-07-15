with sellers as (
    select * from {{ ref('stg_sellers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select
        oi.seller_id,
        count(distinct oi.order_id) as total_orders,
        sum(oi.price) as total_revenue,
        count(distinct oi.product_id) as distinct_products_sold,
        min(o.purchased_at) as first_sale_at,
        max(o.purchased_at) as last_sale_at
    from {{ ref('stg_order_items') }} oi
    left join {{ ref('stg_orders') }} o using (order_id)
    group by 1
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['s.seller_id']) }}
            as seller_key,
        s.seller_id,
        s.zip_code_prefix,
        s.seller_city,
        s.seller_state,
        coalesce(oi.total_orders, 0) as lifetime_orders,
        coalesce(oi.total_revenue, 0) as lifetime_revenue,
        oi.distinct_products_sold,
        oi.first_sale_at,
        oi.last_sale_at
    from sellers s
    left join order_items oi using (seller_id)
)

select * from final