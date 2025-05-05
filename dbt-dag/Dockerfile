FROM apache/airflow:3.0.0-python3.12

USER root

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

USER airflow

COPY dags/ /opt/airflow/dags/
COPY dbt-project/ /opt/airflow/dbt-project/

EXPOSE 8080

ENTRYPOINT ["airflow"]
CMD ["standalone"]