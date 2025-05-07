with channel as(
  SELECT
    n.dim_user_id,
    n.fct_date,
    floor(date_diff(date(n.fct_date), date(u.dim_creation_date), year)) as years_since_creation,
    date_diff(date(n.fct_date), date(u.dim_creation_date), month) as months_since_creation,
    n.fct_channel,
  FROM {{ ref('wh_notifications') }} n
  join `neo_bank.wh_users` u
    on n.dim_user_id = u.dim_user_id
  where fct_status = "SENT"
)
select
  dim_user_id,
  fct_date,
  years_since_creation,
  months_since_creation,
  fct_channel,
  count(1) as cnt_notifications
from channel
group by
  dim_user_id,
  fct_date,
  years_since_creation,
  months_since_creation,
  fct_channel