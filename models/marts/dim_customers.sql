with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        min(purchased_at) as first_order_at,
        max(purchased_at) as last_order_at,
        count(order_id) as total_orders
    from orders
    group by 1
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }}
            as customer_key,
        c.customer_id,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        coalesce(co.total_orders, 0) as lifetime_orders,
        co.first_order_at,
        co.last_order_at
    from customers c
    left join customer_orders co using (customer_id)
)

select * from final