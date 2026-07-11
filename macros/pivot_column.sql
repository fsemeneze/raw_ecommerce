{% macro pivot_column(column_name, values, agg_func='sum', value_column='payment_value') %}
    {% for value in values %}
        {{ agg_func }}(case when {{ column_name }} = '{{ value }}' then {{ value_column }} else 0 end) as {{ value }}_{{ value_column }}
        {%- if not loop.last %},{% endif %}
    {% endfor %}
{% endmacro %}
