import pandas as pd
import requests

def get_country_info(df):
    country_infos = []

    for country in df['dim_country']:
        try:
            response = requests.get(f'https://restcountries.com/v3.1/name/{country}')
            response.raise_for_status()
            data = response.json()

            info = data[0]
            country_info = {
                'dim_country': country,
                'official_name': info['name']['official'],
                'capital': info['capital'][0] if 'capital' in info else None,
                'population': info['population'],
                'area': info['area']
            }
            country_infos.append(country_info)

        except Exception as e:
            print(f"Erreur pour {country}: {e}")

    country_info_df = pd.DataFrame(country_infos)

    print(country_info_df)
    return country_info_df