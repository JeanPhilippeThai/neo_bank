# POC de procecssus ELT et reverse ETL dans un environnement Google
**Stack: Python, SQL, Bigquery, DBT core, Airflow, n8n, Census, Google Sheet, PowerBI, Docker, Ubuntu**

Revolut est une banque en ligne qui souhaite suivre la rétention, le churn, l'activité de ses clients.
La difficulté est de partir de la table des faits des transactions pour évaluer ces KPIs.

**Le but du projet est de mettre en oeuvre une data stack moderne dans un environnement Google d'entreprise.**

## Résultats principaux
- Modélisation de l'activité des utilisateurs sous la forme "user_id, is_activte, starting_date, ending_date" (dbt-project/mart/mart_user_is_active)
- Mise à disposition de toutes les données (externes et sur cloud) **pour les métiers et le managemenet** via le reverse ETL


## Processus complet

![Diagramme sans nom drawio](https://github.com/user-attachments/assets/63158076-cf54-456b-abc6-d3cb00ba2969)
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

La BI se fait sous PowerBI.

![powerbi](https://github.com/user-attachments/assets/fc1c9d96-ed31-4093-8a09-12960ea78c41)
|:--:|
| *Image 2 - Graphiques PowerBI* |

## Architecture et choix techniques

Partie Cloud:
- Datawarehouse: Bigquery pour son utilisation intuitive
- Transformations: SQL et DBT fonctionnent très bien avec Bigquery en plus de fournir un suivi clair du code via Github.
- Orchecstration: Airflow

Extraction des données externes:
- Appels API: Python
- Stockage des données: Google sheet pour le défi technique, Bigquery serait sinon plus pertinent à mon avis pour un cas d'utilisation réel
- Interaction avec les utilisateurs: n8n qui permet d'envoyer des notifications 

Reverse ETL et activation des données
- Census pour facilité le renvoi des données vers Google Sheet, qui aurait pu être également un CRM, Google Ads etc
- PowerBI pour des tableaux BI destinés aux métiers
