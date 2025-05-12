-- Utilisateurs premium actifs
with premium_users as(
  select
    m.*
  from {{ ref('mart_user_is_active') }} m
  join {{ ref('wh_users') }} u
    on m.dim_user_id = u.dim_user_id
  where u.dim_plan != 'STANDARD'
),
-- Utilisateurs premium actifs en début de mois
active_start_of_month as (
  select
    date_trunc(date_month, month) as month,
    count(distinct dim_user_id) as active_users_start
  from 
    unnest(generate_date_array(
      (select min(date_trunc(starting_date, month)) from premium_users), 
      current_date(), 
      interval 1 month
    )) as date_month
  join premium_users
    on date_trunc(date_month, month) between date_trunc(starting_date, month) and date_trunc(ending_date, month)
    and is_active = true
  group by month
),

-- Utilisateurs actifs en fin de mois, hors nouveaux arrivant
active_end_of_month as (
  select
    date_trunc(date_month, month) as month,
    count(distinct dim_user_id) as active_users_end
  from 
    unnest(generate_date_array(
      (select min(date_trunc(starting_date, month)) from premium_users), 
      current_date(), 
      interval 1 month
    )) as date_month
  join premium_users
    on last_day(date_month, month) between starting_date and ending_date
    and is_active = true
    and date_trunc(starting_date, month) < date_trunc(date_month, month) -- exclut les nouveaux du mois
  group by month
),

-- Nouveaux utilisateurs arrivés pendant le mois
new_users_month as (
  select
    date_trunc(starting_date, month) as month,
    count(distinct dim_user_id) as new_users_count
  from premium_users
  where is_active = true
  group by month
)

-- Table finale
select
  a.month,
  a.active_users_start,
  b.active_users_end,
  coalesce(n.new_users_count, 0) as new_users_count,
  round(1 - (b.active_users_end / a.active_users_start), 4) as churn_rate,
  round(b.active_users_end / a.active_users_start, 4) as retention_rate,
  round(coalesce(n.new_users_count, 0) / a.active_users_start, 4) as growth_rate,
  -- Devrait être égale à active_users_start du mois suivant
  b.active_users_end + coalesce(n.new_users_count, 0) as calculated_next_month_start
from active_start_of_month a
join active_end_of_month b on a.month = b.month
left join new_users_month n on a.month = n.month
order by a.month
