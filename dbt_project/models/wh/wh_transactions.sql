SELECT distinct
  REGEXP_EXTRACT(transaction_id, r'(\d+)$') as dim_transaction_id,
  REGEXP_EXTRACT(user_id, r'(\d+)$') as dim_user_id,
  transactions_type as fct_transactions_type,
  transactions_currency as fct_transactions_currency,
  amount_usd as fct_amount_usd,
  transactions_state as fct_transactions_state,

  -- ea_cardholderpresence contient des valeurs null et ~5k 'UNKNOWN' sur 2.7M lignes
  case
    when lower(ea_cardholderpresence) = 'unknown' then null
    else ea_cardholderpresence
  end as fct_ea_card_holderpresence, 
  cast(ea_merchant_mcc as int) as dim_ea_merchant_mcc,

  case
    -- On enlève les noms de ville seulement composés de nombres et/ou d'espace et/ou de tiret
    -- On enlève les blocs de chiffres devant les noms
    when REGEXP_CONTAINS(ea_merchant_city, r'^[\d\-\s]+$')  then null
    when REGEXP_CONTAINS(ea_merchant_city, r'^\d+') OR REGEXP_CONTAINS(ea_merchant_city, r'\d+$') 
      then REGEXP_REPLACE( REGEXP_REPLACE(ea_merchant_city, r'^\d+\s*', ''),
                            r'\s*\d+$',
                            ''
      )
    else ea_merchant_city
  end as dim_ea_merchant_city,

  ea_merchant_country as dim_ea_merchant_country,

  direction as fct_direction,
  date(created_date) as fct_date,
  extract(hour from created_date) as fct_hour

FROM {{ source('bigquery_dataset', 'transactions') }}
where
  REGEXP_EXTRACT(transaction_id, r'(\d+)$') is not null
  and REGEXP_EXTRACT(user_id, r'(\d+)$') is not null
  and created_date is not null
