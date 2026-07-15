with payments as (
    select * from {{ ref('stg_payments') }}
),

final as (
    select
        order_id,
        count(distinct payment_sequence) as total_payments,
        {{ pivot_column('payment_type', ['credit_card', 'boleto', 'voucher', 'debit_card']) }},
        coalesce(max(payment_installments), 0) as max_installments,
        coalesce(sum(payment_value), 0) as total_payment_value
    from payments
    group by order_id
)

select
    order_id,
    total_payments,
    coalesce(credit_card_payment_value, 0) as credit_card_value,
    coalesce(boleto_payment_value, 0) as boleto_value,
    coalesce(voucher_payment_value, 0) as voucher_value,
    coalesce(debit_card_payment_value, 0) as debit_card_value,
    max_installments,
    total_payment_value
from final