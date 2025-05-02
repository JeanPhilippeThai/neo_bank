from google.cloud import bigquery
import pandas as pd
import pycountry

def get_country():
    client = bigquery.Client()
    project_id = "test-project-457508"
    dataset_id = "neo_bank"
    table_id = "wh_users"

    query = f"""
        select distinct dim_country
        from `{project_id}.{dataset_id}.{table_id}`
    """

    query_job = client.query(query)
    results = query_job.result()

    df = results.to_dataframe()
    return df


def code_to_country_name(code):
    try:
        country = pycountry.countries.get(alpha_2=code.upper())
        return country.name if country else None
    except:
        return None

