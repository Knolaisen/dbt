{% test valid_phone_number(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} is not null
  and (
    not regexp_like(
      to_varchar({{ column_name }}),
      '^[+]?[0-9 ()-]{7,20}$'
    )
    or length(
      regexp_replace(to_varchar({{ column_name }}), '[^0-9]', '')
    ) not between 7 and 15
  )

{% endtest %}