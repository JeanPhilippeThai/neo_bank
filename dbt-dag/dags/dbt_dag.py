from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime, timedelta
from airflow.providers.standard.operators.python import PythonOperator

# Paramètres du DAG
default_args = {
    'owner': 'jpbap',
    'start_date': datetime.now() - timedelta(days=1),
    'retries': 1,
}

with DAG(
    dag_id='dbt_bigquery',
    default_args=default_args,
    schedule='0 12 * * *',  # Exécution tous les jours à midi
    dagrun_timeout=timedelta(minutes=5),
    catchup=False,
    tags=['dbt', 'bigquery'],
) as dag:

    # PROJET DBT 
    ## Chemins
    dbt_project_dir = '/home/jpbap/neo_bank/dbt-project'
    dbt_profiles_dir = '/home/jpbap/.dbt'

    ## dbt run
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command=f'cd {dbt_project_dir} && dbt run --profiles-dir {dbt_profiles_dir}',
    )

    ## dbt test
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command=f'cd {dbt_project_dir} && dbt test --profiles-dir {dbt_profiles_dir}',
    )

    # PROJET PYTHON
    def run_main():
        import subprocess
        subprocess.run([
            '/home/jpbap/miniconda3/envs/neo_bank3/bin/python',
            '/home/jpbap/neo_bank/dev/main.py'
        ], check=True)

    python_main = PythonOperator(
        task_id='python_main',
        python_callable=run_main,
    )
    
    # EXECUTION
    dbt_run >> dbt_test >> python_main