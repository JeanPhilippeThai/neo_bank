with yearly_agg as(
  select
    dim_user_id,
    years_since_creation,
    fct_direction,
    count(dim_transaction_id) as cnt_transactions,
    count(case when fct_direction='OUTBOUND' then 1 else 0 end) as cnt_outboud_transactions,
    count(case when fct_direction='INBOUND' then 1 else 0 end) as cnt_inbound_transactions,
    trunc(sum(case when fct_direction='OUTBOUND' then fct_amount_usd else 0 end),0) as sum_spent,
    trunc(sum(case when fct_direction='INBOUND' then fct_amount_usd else 0 end),0) as sum_received,
  from {{ref('int_transactions_since_creation') }}
  group by
    dim_user_id,
    years_since_creation,
    fct_direction
)
select 
  y.*,
  extract(year from current_date) - u.dim_birth_year as scd_age,
  u.dim_country,
  u.dim_city,
  u.dim_plan,
  u.dim_crypto_unlocked,
  u.scd_contacts,
  u.scd_num_referrals,
  u.scd_num_successful_referrals,
  ud.dim_os
from yearly_agg y
join {{ ref('wh_users')}} u
  on y.dim_user_id = u.dim_user_id
join {{ ref('wh_users_devices')}} ud
  on ud.dim_user_id = y.dim_user_id
