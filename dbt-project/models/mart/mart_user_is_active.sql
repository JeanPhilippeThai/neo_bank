-- Un utilisateur n'est pas actif si cela fait plus de 90 jours qu'il n'a pas fait de transaction

-- On cherche à avoir une table
-- user_id, starting_date, end_date, is_active = boolean pour connaitre les périodes durant lesquelles 

-- Lourd mais à faire seulement une fois
-- Ou lorsqu'on a perdu tout l'historique
-- Alimenter la table dans le futur sera très peu couteux

-- -------------------------------
-- DETECTION DE PETITE PERIODE DACTIVITE OU DINACTIVITE ENTRE DEUX TRANSACTIONS SEULEMENT 
-- -------------------------------
with transactions as(
  select distinct
    dim_user_id,
    fct_date,
    dense_rank() over (partition by dim_user_id order by fct_date) as rn_date
  from {{ ref('wh_transactions') }}
),
previous_and_actual_date as(
  select
    t1.dim_user_id,
    t2.fct_date as fct_previous_transaction_date,
    t1.fct_date as fct_transaction_date
  from transactions t1
  left join transactions t2
    on t1.dim_user_id = t2.dim_user_id and (t1.rn_date-1) = t2.rn_date
),
-- On ajoute les utilisateurs qui ont crée leurs compte sans jamais avoir fait de transaction
add_new_inactive_client as(
  select
    u.dim_user_id,
    u.dim_creation_date as fct_previous_transaction_date,
    null as fct_transaction_date
  from {{ ref('wh_users')}} u
  left join {{ ref('wh_transactions') }} t
    on u.dim_user_id = t.dim_user_id
  where t.dim_transaction_id is null

  union all

  select
    *
  from previous_and_actual_date
),
-- Il y a des day_diff null pour les utilisateurs inscrits sans avoir jamais fait de transaction
day_diff_table as(
  select
    *,
    date_diff(fct_transaction_date, fct_previous_transaction_date, day) as day_diff
  from add_new_inactive_client
),
is_active_primitive as(
  select
    *,
    case
      -- Si lutilisateur na pas encore fait de transaction
      when (day_diff is null) and (fct_transaction_date is null) then FALSE
      -- Sil ny a pas 90 jours entre deux transactions, lutilisateur est actif
      -- Entre previous_transaction_date et transaction_date
      when day_diff<=90 then TRUE
      -- Sinon il ne l'est plus entre previous_transaction_date et transaction_date
      -- Il passe actif néanmoins lors de transaction_date, au moins pendant 1 jour!
      -- Ce cas est géré plus bas dans le cte duplicate_transaction
      else FALSE
    end as is_active
  from day_diff_table
),

-- -------------------------------
-- DETECTION DES PERIODES GLOBALES DACTIVITE ET NON ACTIVITE ENTRE PLUSIEURS TRANSACTIONS
-- -------------------------------
activity_changes_flag as (
  select
    *,
    case
      when is_active != lag(is_active) over (
        partition by dim_user_id 
        order by fct_previous_transaction_date asc, fct_transaction_date asc, day_diff nulls first
      )
      then 1
      else 0
    end as activity_has_changed
  from is_active_primitive
),
activity_streak as(
  select
    dim_user_id,
    fct_previous_transaction_date,
    fct_transaction_date,
    is_active,
    day_diff,
    sum(activity_has_changed) over (
      partition by dim_user_id
      order by fct_previous_transaction_date asc, fct_transaction_date asc, day_diff nulls first
    ) as cnt_activity_streak
  from activity_changes_flag
),
new_rn as(
  select
    dim_user_id,
    fct_previous_transaction_date,
    fct_transaction_date,
    is_active,
    cnt_activity_streak,
    day_diff,
    row_number() over(
      partition by dim_user_id, cnt_activity_streak
      order by 
        cnt_activity_streak asc, 
        fct_previous_transaction_date asc, 
        fct_transaction_date asc, 
        day_diff nulls first
    ) as rn_asc,
    row_number() over(
      partition by dim_user_id, cnt_activity_streak
      order by 
        cnt_activity_streak desc,
        fct_previous_transaction_date desc, 
        fct_transaction_date desc, 
        day_diff nulls last
    ) as rn_desc,

  from activity_streak
),

-- Clause WHERE:
-- On garde seulement les dates qui nous permettront
-- de créer les starting_date, end_date, is_active=bool
with_creation_date as(
  select
    rn.dim_user_id,
    case
      when fct_previous_transaction_date is null then u.dim_creation_date
      else fct_previous_transaction_date
    end as fct_previous_transaction_date,
    rn.fct_transaction_date,
    rn.day_diff,
    rn.is_active,
    rn.rn_asc,
    rn.rn_desc
  from `neo_bank.wh_users` u
  join new_rn rn
    on u.dim_user_id = rn.dim_user_id 
  where 
    is_active is FALSE
    OR (rn_asc=1 OR rn_desc=1)
),
-- On duplique chaque transaction qui reste pour capter facilement le fait
-- qu'entre transaction_date et transaction__date lui même, l'utilisateur est actif
-- ! les utilisateurs sans transactions sont dupliques aussi
-- on les retire juste apres avec un where day diff >-1
-- au lieu d'ajouter trop de case when ici

-- Etape qu'on aurait pu faire beaucoup plus tot mais qui demande plus de memoire
-- surtout dans le cas où beaucoup d'utilisateur on de longue période avec beaucoup de transactions
duplicate_transaction as(
  select
    dim_user_id,
    fct_transaction_date as fct_previous_transaction_date,
    fct_transaction_date,
    case
      when fct_transaction_date is null then -1 
      else 0
    end as day_diff,
    TRUE as is_active
  from with_creation_date

  UNION ALL

  select
    dim_user_id,
    fct_previous_transaction_date,
    fct_transaction_date,
    day_diff,
    is_active
  from with_creation_date

),
-- On ajoute les row_number de nouveau pour obtenir les starting date et ending date
-- de chaque periode dactivite ou inactivite
clean_period as(
  select
    *,
    row_number() over (
      partition by dim_user_id, is_active 
      order by fct_previous_transaction_date asc, fct_transaction_date asc
    ) rn_asc,
    row_number() over (
      partition by dim_user_id, is_active 
      order by fct_previous_transaction_date desc, fct_transaction_date desc
    ) rn_desc
  from duplicate_transaction
  where day_diff >-1 or day_diff is null -- pour gérer la duplication dutilisateur sans transaction du cte plus haut
),
activity_changes_flag_2 as (
  select
    *,
    case
      when is_active != lag(is_active) over (
        partition by dim_user_id 
        order by fct_previous_transaction_date asc, fct_transaction_date asc, day_diff nulls first
      )
      then 1
      else 0
    end as activity_has_changed
  from clean_period
),
activity_streak_2 as(
  select
    dim_user_id,
    fct_transaction_date,
    fct_previous_transaction_date,
    is_active,
    day_diff,
    sum(activity_has_changed) over (
      partition by dim_user_id
      order by fct_previous_transaction_date asc, fct_transaction_date asc, day_diff nulls first
    ) as cnt_activity_streak
  from activity_changes_flag_2
),
new_rn_2 as(
  select
    dim_user_id,
    fct_previous_transaction_date,
    fct_transaction_date,
    is_active,
    cnt_activity_streak,
    day_diff,
    row_number() over(
      partition by dim_user_id, cnt_activity_streak
      order by 
        cnt_activity_streak asc, 
        fct_previous_transaction_date asc, 
        fct_transaction_date asc, 
        day_diff nulls first
    ) as rn_asc,
    row_number() over(
      partition by dim_user_id, cnt_activity_streak
      order by 
        cnt_activity_streak desc,
        fct_previous_transaction_date desc, 
        fct_transaction_date desc, 
        day_diff nulls last
    ) as rn_desc,

  from activity_streak_2
),

-- -------------------------------
-- TABLE FINALE
-- -------------------------------
final_table as(
  select
    t1.dim_user_id,
    t1.is_active,

    case
      when t1.day_diff is null then t1.fct_previous_transaction_date
      when t1.is_active is false then t1.fct_previous_transaction_date
      else t1.fct_transaction_date
    end as starting_date,

    case
      when t1.day_diff is null then t1.fct_transaction_date
      when t1.is_active is false then t1.fct_transaction_date
      else t2.fct_transaction_date
    end as ending_date,

  from new_rn_2 t1
  join new_rn_2 t2
    on t1.dim_user_id = t2.dim_user_id
    and t1.cnt_activity_streak = t2.cnt_activity_streak
    and t1.rn_asc = t2.rn_desc
  where t1.rn_asc=1
  -- a commenter si besoin
  order by t1.dim_user_id, t1.fct_transaction_date, t1.fct_previous_transaction_date asc, t1.day_diff nulls first
)
select *
from final_table


