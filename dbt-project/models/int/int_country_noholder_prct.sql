-- Permet d'analyser le pourcentage de transactoins où l'acheteur est physiquement présent
-- Au moment de la transaction
-- Groupé par mois et par pays

-- Permet de créer mart_noholder_bycountry et mart_noholder_global

with filtered_transactions as(
  SELECT
    dim_ea_merchant_country,
    dim_transaction_id,
    fct_transactions_type,
    fct_ea_card_holderpresence,
    fct_amount_usd,
    extract(year from fct_date) as fct_year,
    extract(month from fct_date) as fct_month,
  FROM {{ ref('wh_transactions') }}
  where
    fct_transactions_state = 'COMPLETED'
),
noholder as(
  select
    dim_ea_merchant_country,
    fct_year,
    fct_month,
    fct_transactions_type,
    count(dim_transaction_id) as cnt_transaction,
    sum(case when fct_ea_card_holderpresence='FALSE' then 1 else 0 end) as cnt_transaction_noholder,
    trunc(sum(case when fct_ea_card_holderpresence='FALSE' then fct_amount_usd else 0 end), 0) as noholder_sum_amount_usd,
    trunc(sum(fct_amount_usd), 0) as total_sum_amount_usd
  from filtered_transactions
  where
    -- On garde les deux types de transactions qui représentent la majorité des transactions
    fct_transactions_type = 'CARD_PAYMENT'
    or fct_transactions_type = 'ATM'
  group by
    dim_ea_merchant_country,
    fct_year,
    fct_month,
    fct_transactions_type
  order by
    dim_ea_merchant_country,
    fct_year asc,
    fct_month asc
)
select
  *,
  coalesce(round(100.0 * cnt_transaction_noholder / cnt_transaction, 0), 0) as prct_noholder,
from noholder