select
    order_key,
    delivery_delay_days
from {{ ref('fct_orders') }}
where delivery_delay_days < 0
