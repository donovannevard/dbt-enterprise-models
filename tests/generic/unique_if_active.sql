{% test unique_if_active(model, column_name, status_column, status_value) %}

SELECT
    *
FROM {{ model }}
WHERE {{ status_column }} = '{{ status_value }}'
GROUP BY {{ column_name }}
HAVING COUNT(*) > 1

{% endtest %}