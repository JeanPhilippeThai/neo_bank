select distinct
  channel as fct_channel,
  status as fct_status,
  cast(REGEXP_EXTRACT(user_id, r'(\d+)$') as int) as dim_user_id,
  date(created_date) as fct_date,
  extract(hour from created_date) as fct_hour,
  case
    when reason = 'PUMPKIN_PAYMENT_NOTIFICATION' then 'PAYMENT_NOTIFICATION'
    else reason
  end as fct_reason
from {{ source('bigquery_dataset', 'notifications') }}
where
  REGEXP_EXTRACT(user_id, r'(\d+)$') is not null
  and created_date is not null