with products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['product_id']) }}
            as product_key,
        product_id,
        product_category_name,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        round(product_weight_g / 1000.0, 2) as product_weight_kg,
        product_length_cm * product_height_cm * product_width_cm
            as product_volume_cm3
    from products
)

select * from final