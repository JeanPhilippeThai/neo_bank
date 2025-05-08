select
    fct_year,
    fct_month,
    sum(cnt_transaction) as cnt_transaction,
    sum(sum_amount_usd) as sum_amount_usd
from {{ ref('int_transactions_monthly')}}
group by
    fct_year,
    fct_month