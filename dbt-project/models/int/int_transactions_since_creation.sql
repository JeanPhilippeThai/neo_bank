select
    t.dim_transaction_id,
    t.dim_user_id,
    t.fct_transactions_type,
    t.fct_transactions_currency,
    t.fct_amount_usd,
    t.fct_transactions_state,
    t.fct_ea_card_holderpresence,
    t.dim_ea_merchant_mcc,
    t.dim_ea_merchant_city,
    t.dim_ea_merchant_country,
    t.fct_direction,
    t.fct_date,
    floor(date_diff(date(t.fct_date), date(u.dim_creation_date), year)) as years_since_creation,
    date_diff(date(t.fct_date), date(u.dim_creation_date), month) as months_since_creation
  from {{ ref('wh_transactions') }} t
  join {{ ref('wh_users') }} u
    on t.dim_user_id = u.dim_user_id