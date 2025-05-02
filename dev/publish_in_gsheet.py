import pandas as pd
import gspread
from oauth2client.service_account import ServiceAccountCredentials
from datetime import date

def publish_in_gsheet(country_info):
    ## ACCES GOOGLE DRIVE
    # Définitions des portées de l'API Google Sheets et Google Drive
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    # Chargement des identifiants du compte de service
    creds = ServiceAccountCredentials.from_json_keyfile_name('/home/jpbap/.config/gspread_pandas/google_secret.json', scope)
    # Autorisation d'accès à Google Sheets
    client = gspread.authorize(creds)

    ## AJOUT DES INFO SUR LES PAYS
    # Ouverture de la feuille Google Sheets
    spreadsheet = client.open("neo_bank")
    sheet = spreadsheet.sheet1

    # Convertion du DataFrame en liste de listes
    data_to_insert = country_info.values.tolist()

    # Insérer les données dans la feuille Google Sheets
    sheet.clear()
    sheet.insert_row(country_info.columns.tolist(), 1)
    sheet.insert_rows(data_to_insert, 2)  

    ## MAJ DE LA DATE DE DERNIERE MAJ
    sheet_date = spreadsheet.get_worksheet(1)

    aujourdhui = date.today()
    aujourdhui_str = aujourdhui.strftime('%Y-%m-%d')  # format 'YYYY-MM-DD'
    date_df = pd.DataFrame({'derniere_maj': [aujourdhui_str]})
    today_date = date_df.values.tolist()

    sheet_date.clear()
    sheet_date.insert_row(date_df.columns.tolist(), 1)
    sheet_date.insert_rows(today_date, 2)

    print("Données enregistrées dans Google Sheets.")
    return 0