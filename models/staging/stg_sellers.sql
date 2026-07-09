with source as (
    select * from {{ source('raw_ecommerce', 'sellers') }}
),

renamed as (
    select
        cast(seller_id as string) as seller_id,
        cast(seller_zip_code_prefix as string) as zip_code_prefix,
        initcap(cast(seller_city as string)) as seller_city,
        upper(cast(seller_state as string)) as seller_state
    from source
)

select * from renamed