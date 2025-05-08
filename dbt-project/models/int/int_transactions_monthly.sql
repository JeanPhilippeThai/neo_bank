-- Nombre de transactions et montant des transactions 
-- par mois et par pays

-- Permet de créer mart_transactions_global et mart_transactions_monthly

with month_year_transaction as(
  SELECT
    dim_transaction_id,
    fct_amount_usd,
    extract(year from fct_date) as fct_year,
    extract(month from fct_date) as fct_month,
    dim_ea_merchant_country
  FROM {{ ref('wh_transactions')}} 
  where fct_transactions_state='COMPLETED'
)
select
  fct_year,
  fct_month,
  dim_ea_merchant_country,
  count(dim_transaction_id) as cnt_transaction,
  round(sum(fct_amount_usd), 0) as sum_amount_usd
from month_year_transaction
group by
  fct_year,
  fct_month,
  dim_ea_merchant_country