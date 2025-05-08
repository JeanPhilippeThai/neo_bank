-- Evolution du nombre de paiement sans le titulaire de carte
-- Worldwide et par mois

SELECT
  fct_year,
  fct_month,
  sum(cnt_transaction) as cnt_transaction,
  sum(cnt_transaction_noholder) as cnt_transaction_noholder,
  sum(noholder_sum_amount_usd) as noholder_sum_amount_usd,
  sum(total_sum_amount_usd) as total_sum_amount_usd,
  sum(prct_noholder*cnt_transaction) / sum(cnt_transaction) as prct_noholder
FROM {{ ref('int_country_noholder_prct') }}
group by
  fct_year,
  fct_month