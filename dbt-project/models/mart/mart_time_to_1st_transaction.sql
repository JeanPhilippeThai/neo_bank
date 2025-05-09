-- On utilise mart_user_is_active qui est plus rapide et moins couteux en mémoire

with cte as(
  SELECT 
    *,
    row_number() over (partition by dim_user_id order by starting_date) as rn
  FROM {{ ref('mart_user_is_active') }}
),
days_diff as(
  select
    dim_user_id,
    extract(year from starting_date) as year_signup,
    extract(month from starting_date) as month_signup,
    date_diff(ending_date, starting_date, day) as days_since_1st_transaction
  from cte
  where 
    rn = 1
    and ending_date is not null
)
select
  year_signup,
  month_signup,
  round(avg(days_since_1st_transaction), 0) as avg_days_since_1st_transaction,
  count(dim_user_id) as cnt_users
from days_diff
group by
  year_signup,
  month_signup
order by
  year_signup,
  month_signup