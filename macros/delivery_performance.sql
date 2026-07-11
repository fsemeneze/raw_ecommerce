{% macro delivery_performance(delivered_at, estimated_delivery_at) %}
    case
        when {{ delivered_at }} > {{ estimated_delivery_at }}
            then 'late'
        when {{ delivered_at }} is not null
            then 'on_time'
        else 'pending'
    end
{% endmacro %}
