{% macro describe_model(model_name) %}
    {% set query %}
        select
            column_name,
            data_type
        from {{ target.database }}.INFORMATION_SCHEMA.COLUMNS
        where table_name = '{{ model_name }}'
          and table_schema = '{{ target.schema }}'
    {% endset %}

    {% if execute %}
        {% set results = run_query(query) %}
        {% do log('=== ' ~ model_name ~ ' columns ===', info=True) %}
        {% for row in results %}
            {% do log(row['column_name'] ~ ' (' ~ row['data_type'] ~ ')', info=True) %}
        {% endfor %}
        {% do log('=== end ===', info=True) %}
    {% endif %}
{% endmacro %}
