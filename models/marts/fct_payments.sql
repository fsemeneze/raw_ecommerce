with payments as (
    select * from {{ ref('stg_payments') }}
),

order_payments as (
    select
        order_id,
        count(distinct payment_sequence) as total_payments,
        sum(case when payment_type = 'credit_card' then payment_value else 0 end)
            as credit_card_value,
        sum(case when payment_type = 'boleto' then payment_value else 0 end)
            as boleto_value,
        sum(case when payment_type = 'voucher' then payment_value else 0 end)
            as voucher_value,
        sum(case when payment_type = 'debit_card' then payment_value else 0 end)
            as debit_card_value,
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
        coalesce(po.credit_card_value, 0) as credit_card_value,
        coalesce(po.boleto_value, 0) as boleto_value,
        coalesce(po.voucher_value, 0) as voucher_value,
        coalesce(po.debit_card_value, 0) as debit_card_value,
        coalesce(po.max_installments, 0) as max_installments,
        coalesce(po.total_payment_value, 0) as total_payment_value
    from order_payments po
)

select * from final