with source as (
    select * from {{ source('raw_ecommerce', 'payments') }}
),

renamed as (
    select
        cast(order_id as string) as order_id,
        cast(payment_sequential as int64) as payment_sequence,
        cast(payment_type as string) as payment_type,
        cast(payment_installments as int64) as payment_installments,
        cast(payment_value as numeric) as payment_value
    from source
)

select * from renamed