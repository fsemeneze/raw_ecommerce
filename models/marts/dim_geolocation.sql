with geolocation as (
    select * from {{ ref('stg_geolocation') }}
),

aggregated as (
    select
        zip_code_prefix,
        any_value(city) as city,
        any_value(state) as state,
        round(avg(latitude), 4) as avg_latitude,
        round(avg(longitude), 4) as avg_longitude
    from geolocation
    group by zip_code_prefix
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['zip_code_prefix']) }}
            as geolocation_key,
        zip_code_prefix,
        city,
        state,
        avg_latitude,
        avg_longitude
    from aggregated
)

select * from final
