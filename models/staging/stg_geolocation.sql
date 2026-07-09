with source as (
    select * from {{ source('raw_ecommerce', 'geolocation') }}
),

renamed as (
    select
        cast(geolocation_zip_code_prefix as string) as zip_code_prefix,
        cast(geolocation_lat as float64) as latitude,
        cast(geolocation_lng as float64) as longitude,
        initcap(cast(geolocation_city as string)) as city,
        upper(cast(geolocation_state as string)) as state
    from source
)

select * from renamed