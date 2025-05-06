# POC de procecssus ELT et reverse ETL dans un environnement Google [en cours d'écriture]
**Stack: Python, Bigquery SQL, Bigquery, DBT, Airflow, n8n, Census, Google Sheet, Looker Studio, Docker, Ubuntu**

**Le but du projet est de mettre en oeuvre une data stack moderne dans un environnement Google d'entreprise.**

## Résultats principaux
- Création d'un datawarehouse prêt à fournir des data marts
- Récupération de données externes via API
- Mise à disposition de toutes les données (externes et sur cloud) **pour les métiers et le managemenet** via le reverse ETL


## Processus complet

![Diagramme sans nom drawio](https://github.com/user-attachments/assets/3e3502bf-378b-47dc-b6eb-ed18776b3488)
|:--:|
| *Image 1 - Schéma ELT et reverse ETL* |

Les données d'origine se trouvent directement sur BigQuery.
Les transformations sont gérées par DBT vers Bigquery (dossier "dbt_project/wh" dans le repo).
Des données supplémentaires sont extraites d'une API via Python puis envoyées vers Google Sheet.
Tout ce processus est orchestré par Airflow.
Dès que le Google Sheet est mis à jour, un mail m'est automatiquement envoyé grâce à n8n.

Census permet le reverse ETL.
Il lit les données de BigQuery et Google Sheet les renvoyer sur Google Sheet pour les métiers théoriques consommateurs de la donnée.
Il est possible d'envoyer ces données vers un CRM, le cloud, une messagerie ou autre.

La BI se fait sous Looker Studio.

## Détail des résultats

### Création du datawarehouse (Bigquery, SQL, DBT, airflow)

### Récupération des données externes (Python, Google Sheet, n8n) 

### Mise à disposition des données pour les métiers et le management (census, docker, Looker Studio, Google Sheet)
