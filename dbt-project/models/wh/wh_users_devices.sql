SELECT distinct
  string_field_0 as dim_os,
  cast(REGEXP_EXTRACT(string_field_1, r'(\d+)$') as int) as dim_user_id,
FROM {{ source('raw_bigquery_dataset', 'devices') }}
where
  (string_field_0 = 'Apple' or string_field_0 = 'Android')
  and REGEXP_EXTRACT(string_field_1, r'(\d+)$') is not null