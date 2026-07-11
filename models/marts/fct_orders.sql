with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

order_metrics as (
    select
        order_id,
        count(distinct order_item_sequence) as total_items,
        sum(price) as total_order_value,
        sum(freight_value) as total_freight,
        count(distinct product_id) as distinct_products,
        count(distinct seller_id) as distinct_sellers
    from order_items
    group by 1
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['o.order_id']) }}
            as order_key,
        {{ dbt_utils.generate_surrogate_key(['o.customer_id']) }}
            as customer_key,
        o.order_id,
        o.purchased_at,
        o.approved_at,
        o.shipped_at,
        o.delivered_at,
        o.estimated_delivery_at,
        o.order_status,
        coalesce(om.total_items, 0) as total_items,
        coalesce(om.total_order_value, 0) as total_order_value,
        coalesce(om.total_freight, 0) as total_freight,
        coalesce(om.distinct_products, 0) as distinct_products,
        coalesce(om.distinct_sellers, 0) as distinct_sellers,
        -- Calculando tempos de ciclo
        timestamp_diff(o.delivered_at, o.purchased_at, day)
            as delivery_delay_days,
        timestamp_diff(o.approved_at, o.purchased_at, hour)
            as approval_hours,
        {{ delivery_performance('o.delivered_at', 'o.estimated_delivery_at') }} as delivery_status,
        fp.total_payment_value as payment_value,
        fp.max_installments as max_installments,
        fr.avg_review_score as avg_review_score,
        fr.avg_review_response_hours as avg_review_response_hours
    from orders o
    left join order_metrics om using (order_id)
    left join {{ ref('fct_payments') }} fp using (order_id)
    left join {{ ref('fct_reviews') }} fr using (order_id)
)

select * from final