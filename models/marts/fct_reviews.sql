with reviews as (
    select * from {{ ref('stg_reviews') }}
),

order_reviews as (
    select
        order_id,
        count(review_id) as total_reviews,
        round(avg(review_score), 2) as avg_review_score,
        min(review_score) as min_review_score,
        max(review_score) as max_review_score,
        count(case when review_score = 5 then 1 end) as five_star_count,
        count(case when review_score = 1 then 1 end) as one_star_count,
        round(avg(
            timestamp_diff(review_answered_at, review_created_at, hour)
        ), 1) as avg_review_response_hours
    from reviews
    group by order_id
)

select * from order_reviews