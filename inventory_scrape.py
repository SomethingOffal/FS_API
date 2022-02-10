import requests
import pandas as pd
from pandas.io.json import json_normalize
import numpy as np
import json
import getpass
import sys
import warnings

warnings.filterwarnings('ignore')
#print ('Argument List:' + str(sys.argv))

if len(sys.argv) == 1:
    email = input('email:')
    pwd = getpass.getpass('pwd:')
else:
    email = sys.argv[1]
    pwd  =  sys.argv[2]
    
#print(email + " " + pwd)

sys.exit('Rtn11 ' + email + " " + pwd)
#sys.exit(0)

#exit

headers = {'accept' : 'application/json', 'content-type' : 'application/json'}

def get_auth_token():
    '''Returns a string containing access token'''
    res = requests.post('https://farsite.online/api/1.0/auth/signin', 
                        data = f'{{"email":"{email}","password":"{pwd}"}}', 
                        headers = headers, verify = False)
    if res.status_code != 201:
        print('Authorization Failed')
        sys.exit(res.text)
        
    else:
        return json.loads(res.text)['accessToken']

def api_get_request(uri):
    '''returns a json dictionary of the results text of the api call'''
    
    res = requests.get(uri, headers = headers, verify = False)
    if res.status_code != 200:
        sys.exit(res.text)
    else:
        return json.loads(res.text)


headers['Authorization'] = f'Bearer {get_auth_token()}'

account_info_dict = {}

account_info_dict['User'] = api_get_request('https://farsite.online/api/1.0/users/')
user_id = account_info_dict['User']['id']

account_info_dict['Sectors'] = api_get_request('https://farsite.online/api/1.0/universe/sectors/my')
account_info_dict['Ships'] = api_get_request(f'https://farsite.online/api/1.0/ships/{user_id}/list')
account_info_dict['Blueprints'] = api_get_request(f'https://farsite.online/api/1.0/blueprints/{user_id}/list')
account_info_dict['Modules'] =  api_get_request(f'https://farsite.online/api/1.0/modules/{user_id}/list')
account_info_dict['Components'] =  api_get_request(f'https://farsite.online/api/1.0/components/{user_id}/list')
account_info_dict['Accessories'] =  api_get_request(f'https://farsite.online/api/1.0/accessories/{user_id}/list')

# Write high level object snapshots to csv

json_normalize(account_info_dict['User']).to_csv('Account.csv', index = False)
json_normalize(account_info_dict['Sectors']).drop([x for x in json_normalize(account_info_dict['Sectors']).keys() if 'owner' in x], axis = 1).to_csv('Sectors.csv', index = False)
json_normalize(account_info_dict['Ships']).drop([x for x in json_normalize(account_info_dict['Ships']).keys() if 'owner' in x], axis = 1).to_csv('Ships.csv', index = False)
json_normalize(account_info_dict['Blueprints']).drop([x for x in json_normalize(account_info_dict['Blueprints']).keys() if 'owner' in x], axis = 1).to_csv('Blueprints.csv', index = False)
json_normalize(account_info_dict['Modules']).drop([x for x in json_normalize(account_info_dict['Modules']).keys() if 'owner' in x], axis = 1).to_csv('Modules.csv', index = False)
json_normalize(account_info_dict['Components']).drop([x for x in json_normalize(account_info_dict['Components']).keys() if 'owner' in x], axis = 1).to_csv('Components.csv', index = False)
# pd.DataFrame(account_info_dict['Accessories']).drop('owner', axis = 1).to_excel(writer, sheet_name = 'Accesories')


    
# Write each ships detail with ship ID as index

all_ships_df = pd.DataFrame()
for index, row in json_normalize(account_info_dict['Ships']).iterrows():
    ship_id = row['id']
    ship_name = row['original.name']
    slots_df = json_normalize(api_get_request(f'https://farsite.online/api/1.0/ships/{ship_id}/slots')['slots'])
    slots_df = slots_df.drop([x for x in slots_df.keys() if 'owner' in x], axis = 1)
    slots_df['Ship_ID'] = ship_id
    slots_df.insert(0, 'Ship Name', ship_name)
    all_ships_df = all_ships_df.append(slots_df)
all_ships_df.set_index('Ship_ID').to_csv('Ships_Slot_Detail.csv')

# Write Bases detail out with Sector full name as index

all_sectors_df = pd.DataFrame()
for index, row in json_normalize(account_info_dict['Sectors']).iterrows():
    planet_name = row['planet.name']
    sector_id = row['index']
    sector_df = json_normalize(api_get_request(f'https://farsite.online/api/1.0/universe/planets/{planet_name}/sectors/{sector_id}/bases'))
    sector_df = sector_df.drop([x for x in sector_df.keys() if 'owner' in x], axis = 1)
    sector_df['Full_Name'] = row['name']
    all_sectors_df = all_sectors_df.append(sector_df)
all_sectors_df.set_index('Full_Name').to_csv('Sectors_Bases_Detail.csv')