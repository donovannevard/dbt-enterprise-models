-- tests/generic/unique_if_active.sql
{% test unique_if_active(model, column_name, status_column, status_value) %}

select *
from {{ model }}
where {{ status_column }} = '{{ status_value }}'
group by {{ column_name }}
having count(*) > 1

{% endtest %}