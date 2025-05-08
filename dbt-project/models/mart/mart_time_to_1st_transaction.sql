with rn as(
  select
    dim_user_id,
    dim_transaction_id,
    fct_date,
    row_number() over (partition by dim_user_id order by fct_date asc) as rn_transaction
  from {{ ref('wh_transactions')}}
),
first_transaction as(
  select
    rn.dim_user_id as dim_user_id,
    date_diff(fct_date, dim_creation_date, day) as days_since_creation,
    extract(year from dim_creation_date) as user_cohort_year,
    extract(month from dim_creation_date) as user_cohort_month
  from rn
  join {{ ref('wh_users')}} u
    on rn.dim_user_id = u.dim_user_id
  where rn_transaction = 1
)
select
  user_cohort_year,
  user_cohort_month,
  count(dim_user_id) as cnt_users,
  round(avg(first_transaction.days_since_creation), 0) as avg_days_since_creation
from first_transaction
group by
  user_cohort_year,
  user_cohort_month
order by user_cohort_year, user_cohort_month