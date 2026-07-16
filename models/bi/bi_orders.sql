with orders as (
    select * from {{ ref('fct_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        o.order_key,
        o.order_id,
        o.purchased_at,
        o.approved_at,
        o.shipped_at,
        o.delivered_at,
        o.estimated_delivery_at,
        format_date('%Y%m', o.purchased_at) as year_month,
        format_date('%Y', o.purchased_at) as year,
        format_date('%m', o.purchased_at) as month,
        o.order_status,
        o.delivery_delay_days,
        o.approval_hours,
        o.delivery_status,
        o.total_items,
        o.total_order_value,
        o.total_freight,
        o.distinct_products,
        o.distinct_sellers,
        o.payment_value,
        o.max_installments,
        o.avg_review_score,
        o.avg_review_response_hours,
        c.customer_key,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        c.lifetime_orders,
        c.first_order_at as customer_first_order_at,
        c.last_order_at as customer_last_order_at
    from orders o
    left join customers c on o.customer_key = c.customer_key
)

select * from final
