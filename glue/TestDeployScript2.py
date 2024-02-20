import json
import boto3
# import sys
# from awsglue.utils import getResolvedOptions
import awswrangler as wr
import base64
import requests
import pandas as pd
import time

omgeving = "70869"
getconnector_naam = "HA_Verkoopfactuurregels"
NUMBER_OF_LAST_DAYS = 1

client_sm = boto3.client('secretsmanager')
response_sm = client_sm.get_secret_value(SecretId='PSP/API/Keys')
keys_values = json.loads(response_sm['SecretString'])

TOKEN_postmarker = keys_values['TOKEN_postmarker']
TOKEN_AFAS = "AfasToken " + str(base64.b64encode(bytes(f"<token><version>1</version><data>{keys_values['TOKEN_AFAS']}</data></token>", 'utf-8')))[2:][:-1]

# args = getResolvedOptions(sys.argv, ['_EnvironmentName'])
# env_name = args['_EnvironmentName']


env_name= 'prd'


def get_afas_url_endpoint(connector_name='afas_currency', skip=0, take=5000):
    return f"https://{str(omgeving)}.rest.afas.online/ProfitRestServices/connectors/{connector_name}?skip={skip}&take={take}"



def download_from_url(url):
    t0 = time.time()
    response = requests.get(url, headers={'Authorization': TOKEN_AFAS})
    if response.status_code in [429, 500, 502, 503, 504]:
        time.sleep(5)
        response = requests.get(url, headers={'Authorization': TOKEN_AFAS})
    try:
        response.raise_for_status()
        df = pd.DataFrame.from_records(response.json()['rows'])
        return time.time() - t0, df
    except requests.exceptions.HTTPError as e:
        print(f'Error in download_from_url() : {e}')
        raise



def enrich_df(df):
    df['date'] = df['date'].str.replace(' - ', '')
    df.loc[df['date'].isna(), 'date'] = df.loc[df['date'].isna(), 'start_date'].str[:7].str.replace('-', '')
    df = df[['currency_code', 'exchange_rate', 'date', 'start_date', 'end_date']]
    df = df.loc[df.currency_code != 'EUR']
    for date_id in set(df.date):
        df_eur = {'currency_code': 'EUR', 'exchange_rate': 1.0, 'date': date_id,
                  'start_date': date_id[:4] + '-' + date_id[4:] + '-01T00:00:00Z',
                  'end_date': '' #date_id[:4] + '-' + date_id[4:] #+ '-30T00:00:00Z'
                  }
        # df = df.append(df_eur, ignore_index=True)
        df = pd.concat([df, pd.DataFrame.from_records([df_eur])])

    df.columns = ['currency_code', 'exchange_rate', 'date_id', 'start_date', 'end_date']
    df['date_id'] = df['date_id'].astype('int')
    df['start_date'] = pd.to_datetime(df['start_date'])
    df['end_date'] = pd.to_datetime(df['end_date'])
    return df

def get_afas_data():
    try:
        rows = 70000
        df_afas = pd.DataFrame()
        i = 0
        while True:
            url = get_afas_url_endpoint(skip=i * rows, take=rows)
            time_taken, df = download_from_url(url)
            # df = enrich_df(df)
            df_afas = pd.concat([df_afas, df])
            print(f'{i} ; total records {df.shape[0]}; time taken: {time_taken}')
            i = i + 1
            if df.shape[0] < rows:
                break
        return df_afas
    except Exception as err:
        print(f'Error in get_afas_data() : {err}')
        raise


df = get_afas_data()
df_afas_exchange_rates = enrich_df(df)

wr.s3.to_parquet(
    df=df_afas_exchange_rates,
    path=f's3://startselect-staging-{env_name}/athena/afas_exchange_rates/',
    dataset=True,
    database='psp_raw',
    table='afas_exchange_rates',
    # partition_cols=['YEAR', 'MONTH', 'DAY'],
    mode='overwrite_partitions'
)