from time import sleep
import random
import requests
import pandas as pd
from pandas.io.json import json_normalize
import numpy as np
import json
import getpass
import sys
import warnings

warnings.filterwarnings('ignore')

def api_get_request(uri):
    '''returns a json dictionary of the results text of the api call'''
    
    res = requests.get(uri, headers = headers, verify = False)
    if res.status_code != 200:
        sys.exit(res.text)
    else:
        return json.loads(res.text)

cols_list = ['id', 'userId', 'owner.username', 'original.id', 'original.name', 'original.type', 'original.size', 'original.tier', 'original.corporation']


owner_blueprints_df = pd.DataFrame(columns = cols_list)
original_blueprints_id_df = pd.DataFrame(columns = ['original.id', 'original.name', 'original.size', 'original.tier'])
blueprint_resource_requirements_df = pd.DataFrame

# get the size of the blueprint list
orig_bp_qty = len(api_get_request('https://farsite.online/api/1.0/config/schemes')['Blueprints'].keys())


# currently, the active user blueprints seem to run from 70 to 2358
# so as not to run forever, break out once we line up all the blueprints
# as of 14-MAR-2022, it took until bp# 1174 to get them all
for i in range(70,2358):
#for i in range(70,110):
    
    sleep(1 + random.random())
    res = json_normalize(api_get_request(f'https://farsite.online/api/1.0/blueprints/{str(i)}'))[cols_list]
    owner_blueprints_df = owner_blueprints_df.append(res)
    
    # check to see if we have an entry in our master list
    if res['original.id'].iloc[0] not in original_blueprints_id_df['original.id'].values:
        original_blueprints_id_df = original_blueprints_id_df.append(res[['original.id', 'original.name', 'original.size', 'original.tier']])
        print('added ' + str(res['original.id'].iloc[0]) + ' ' + res['original.name'].iloc[0])
    if original_blueprints_id_df.shape[0] == orig_bp_qty:
        break

original_blueprints_id_df = original_blueprints_id_df.rename(columns = {'original.id':'id', 'original.name':'name', 'original.size':'size', 'original.tier':'tier'})
original_blueprints_id_df['tier'] = original_blueprints_id_df['tier'].astype(int)
original_blueprints_id_df['id'] = original_blueprints_id_df['id'].astype(int)
original_blueprints_id_df = original_blueprints_id_df.set_index('id')
original_blueprints_id_df.to_csv('blueprints.csv')