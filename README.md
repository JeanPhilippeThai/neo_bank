# Transformation et analyse de transactions bancaires
**Stack: Python, Bigquery SQL, Bigquery, DBT, Airflow, n8n, Census, Google Sheet, Looker Studio, Docker, Ubuntu**

Ce cas concret de base de données de transactions bancaires anonymisées permet de mettre en oeuvre une stack data moderne.
**Le but du projet est de proposer un POC de processus ELT et reverse ETL**

Les données d'origine se trouvent directement sur BigQuery.
Les transformations sont gérées par DBT vers Bigquery (dossier "dbt_project/wh" dans le repo).
Des données supplémentaires sont extraites d'une API via Python puis envoyées vers Google Sheet.
Tout ce processus est orchestré par Airflow.
Dès que le Google Sheet est mis à jour, un mail m'est automatiquement envoyé grâce à n8n.

Census permet le reverse ETL.
Il lit les données de BigQuery et Google Sheet les renvoyer sur Google Sheet pour les métiers théoriques consommateurs de la donnée.
Il est possible d'envoyer ces données vers un CRM, le cloud, une messagerie ou autre.

La BI se fait sous Looker Studio.

![Diagramme sans nom drawio](https://github.com/user-attachments/assets/3e3502bf-378b-47dc-b6eb-ed18776b3488)
|:--:|
| *Image 1 - Schéma ELT et reverse ETL* |

