from bigquery_get_country import get_country, code_to_country_name
from get_country_info import get_country_info
from publish_in_gsheet import publish_in_gsheet

def main():
    # Récupération de la liste des pays dans lesquels habitent les clients
    users_country = get_country()
    users_country['dim_country'] = users_country['dim_country'].apply(code_to_country_name)

    # Enrichissement du df des pays avec des infos sur le pays à l'aide de l'API restcountries
    users_country_info = get_country_info(users_country)

    # Mise à jour de gsheet avec users_country_info
    publish_in_gsheet(users_country_info)

    return 0
    
if __name__ == "__main__":
    main()