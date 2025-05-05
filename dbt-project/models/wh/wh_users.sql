SELECT distinct
  REGEXP_EXTRACT(user_id, r'(\d+)$') as dim_user_id,
  birth_year as dim_birth_year,
  country as dim_country,

  CASE
    -- On enlève les noms de ville seulement composés de nombres et/ou d'espaces et/ou de tirets
    WHEN REGEXP_CONTAINS(city, r'^[\d\-\s]+$') THEN NULL

    -- On enlève les blocs de chiffres au début et à la fin
    WHEN REGEXP_CONTAINS(city, r'^\d+') OR REGEXP_CONTAINS(city, r'\d+$') THEN
      CONCAT(
        UPPER(SUBSTR(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(city), r'^\d+\s*', ''), r'\s*\d+$', ''), 1, 1)),
        SUBSTR(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(city), r'^\d+\s*', ''), r'\s*\d+$', ''), 2)
      )

    -- Sinon on reformate aussi (même sans nettoyage)
    ELSE CONCAT(
      UPPER(SUBSTR(LOWER(city), 1, 1)),
      SUBSTR(LOWER(city), 2)
    )
  END AS dim_city,

  date(created_date) as dim_creation_date,
  user_settings_crypto_unlocked as fct_crypto_unlocked,
  plan as dim_plan,
  cast(attributes_notifications_marketing_email as int) as dim_notifications_marketing_email,
  cast(attributes_notifications_marketing_push as int) as dim_notifications_marketing_push,
  cast(num_contacts as int) as scd_contacts,
  cast(num_referrals as int) as scd_num_referrals,
  cast(num_successful_referrals as int) as scd_num_successful_referrals

FROM {{ source('bigquery_dataset', 'users') }}