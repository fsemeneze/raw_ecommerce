with payments as (
    select * from {{ ref('stg_payments') }}
),

order_payments as (
    select
        order_id,
        count(distinct payment_sequence) as total_payments,
        {{ pivot_column('payment_type', ['credit_card', 'boleto', 'voucher', 'debit_card']) }},
        max(payment_installments) as max_installments,
        sum(payment_value) as total_payment_value
    from payments
    group by 1
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['po.order_id']) }}
            as payment_key,
        order_id,
        coalesce(po.credit_card_payment_value, 0) as credit_card_value,
        coalesce(po.boleto_payment_value, 0) as boleto_value,
        coalesce(po.voucher_payment_value, 0) as voucher_value,
        coalesce(po.debit_card_payment_value, 0) as debit_card_value,
        coalesce(po.max_installments, 0) as max_installments,
        coalesce(po.total_payment_value, 0) as total_payment_value
    from order_payments po
)

select * from final