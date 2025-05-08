-- Evolution du nombre de paiement sans le titulaire de carte
-- Par pays et par mois

SELECT
  *
FROM {{ ref('int_country_noholder_prct') }}