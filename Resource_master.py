import requests
import pandas as pd
from pandas.io.json import json_normalize
import numpy as np
import json
import getpass
import sys
import warnings

warnings.filterwarnings('ignore')

headers = {'accept' : 'application/json', 'content-type' : 'application/json'}

def api_get_request(uri):
    '''returns a json dictionary of the results text of the api call'''
    
    res = requests.get(uri, headers = headers, verify = False)
    if res.status_code != 200:
        sys.exit(res.text)
    else:
        return json.loads(res.text)


# Create a dictionary of dictionaries for all universe data:
overall_data_dict = {}
overall_data_dict['originals'] = api_get_request('https://farsite.online/api/1.0/components/originals')
overall_data_dict['contracts'] = api_get_request('https://farsite.online/api/1.0/contracts')
overall_data_dict['config'] = api_get_request('https://farsite.online/api/1.0/config')
overall_data_dict['modules'] = api_get_request('https://farsite.online/api/1.0/config/modules')
overall_data_dict['schemes'] = api_get_request('https://farsite.online/api/1.0/config/schemes')


# Create a set of dataframes representing the major inventory items:

# Resources
resources_df = pd.DataFrame(overall_data_dict['config']['Resources']).set_index('id')

# Components
components_df = pd.DataFrame(overall_data_dict['originals']).set_index('id')

# Component Assembly Requirements
# Creates two dataframes:
# 1 - component_main_requirements - the high level inputs (credits, duration, cooldown)
# 2 - component_resource_requirements - the resources required to make the component

component_resource_requirements_df = pd.DataFrame()

# Flattening this out isn't so easy
# walk through each component and flatten each?
for component_key, component_value in overall_data_dict['schemes']['Bases']['Actions']['5']['1'].items():
    if len(component_value['Requirements']['Resources']) > 0:
        # Start at the number of resources to define each row in our entry
        for key, value in component_value['Requirements']['Resources'].items():
            line_item = {'component_id' : component_key, 
                        'resource_id' : key, 
                        'resource_qty' : value}
            component_resource_requirements_df = component_resource_requirements_df.append(line_item, ignore_index = True)
            
component_resource_requirements_df['component_id'] = component_resource_requirements_df['component_id'].astype(int)
component_resource_requirements_df['resource_id'] = component_resource_requirements_df['resource_id'].astype(int)
component_resource_requirements_df = component_resource_requirements_df.set_index('component_id')

component_main_requirements_df = pd.DataFrame()

for component_key, component_value in overall_data_dict['schemes']['Bases']['Actions']['5']['1'].items():
    line_item = {'component_id' : component_key, 
                'duration' : component_value['Duration'], 
                'credits' : component_value['Requirements']['Credits']}
    component_main_requirements_df = component_main_requirements_df.append(line_item, ignore_index = True)

component_main_requirements_df['component_id'] = component_main_requirements_df['component_id'].astype(int)
component_main_requirements_df = component_main_requirements_df.set_index('component_id')

# Get current blueprint requirements
blueprint_component_requirements_df = pd.DataFrame()

for blueprint_key, blueprint_value in api_get_request('https://farsite.online/api/1.0/config/schemes')['Blueprints'].items():
    if len(blueprint_value['Requirements']['Components']) > 0:
        # Start at the number of resources to define each row in our entry
        for key, value in blueprint_value['Requirements']['Components'].items():
            line_item = {'blueprint_id' : blueprint_key, 
                        'component_id' : key, 
                        'component_qty' : value}
            blueprint_component_requirements_df = blueprint_component_requirements_df.append(line_item, ignore_index = True)

blueprint_component_requirements_df['blueprint_id'] = blueprint_component_requirements_df['blueprint_id'].astype(int)
blueprint_component_requirements_df['component_id'] = blueprint_component_requirements_df['component_id'].astype(int)
blueprint_component_requirements_df = blueprint_component_requirements_df.set_index('blueprint_id')

# usage (one possible method)
# Make a Small Booster Amplifier (components_df id == 384):

# 1.  join the components table to the main resource table:
#
# components_df.loc[(components_df['name'] == 'Booster amplifier') & (components_df['size'] == 'S')].join(component_main_requirements_df)
#   >>id volume	name	            code	tier	size	type	cooldown	credits	duration							
#     384	1	Booster amplifier	mc121	0	    S	    amplifier	0.0	     0.0	0.0
#
# 2. join the resources table to the component resource table, based on the component id of 384, and join the component name to be friendly:
#
# resources_df.merge(component_resource_requirements_df.loc[[384]], left_index = True, right_on = 'resource_id').join(components_df, rsuffix = '_comp'):
#
# >>
#       code	name	type	group	color	volume	resource_id	resource_qty	volume_comp	name_comp	code_comp	tier	size	type_comp
# 384	OXm48	Oxygen	Material	Gas	#a89a73	1	48	0.0	1	Booster amplifier	mc121	0	S	amplifier
# 384	TIm56	Tin	Material	Metal	#85a1bb	1	56	0.0	1	Booster amplifier	mc121	0	S	amplifier
# 384	ZIm61	Zinc	Material	Metal	#85a1bb	2	61	0.0	1	Booster amplifier	mc121	0	S	amplifier
# 384	RmCO2	Regular CO2	Material	Side	#999999	1	96	0.0	1	Booster amplifier	mc121	0	S	amplifier


# ------------------------------------------
# Mining and Production

# Mining Requirements
# This doesn't include Tax collected!


mining_requirements_df = pd.DataFrame()

for key, value in overall_data_dict['schemes']['Bases']['Actions']['1']['1'].items():
    line_item = {'resource_id' : key, 
                'duration' : value['Duration'], 
                'extraction' : value['Extraction'], 
                'credits' : value['Requirements']['Credits']}
    mining_requirements_df = mining_requirements_df.append(line_item, ignore_index = True)

mining_requirements_df['resource_id'] = mining_requirements_df['resource_id'].astype(int)
mining_requirements_df = mining_requirements_df.set_index('resource_id')

# Usage
# How long does it take to mine Scandium and for what cost and volume?
# resources_df.loc[resources_df['code'] == 'SOo23'].join(mining_requirements_df)
# >>id	code	name	type	group	color	volume	credits	duration	extraction
#  126	SOo23	Scandium ore	Ore	Metal	#85a1bb	1	200.0	27600.0	20.0


# Refining Requirements
# Creates two dataframes - main input requirements based on the input resource
# and an output dataframe

refinery_main_requirements_df = pd.DataFrame()

for refined_resource_key, refined_resource_value in overall_data_dict['schemes']['Bases']['Actions']['2']['1'].items():
    line_item = {'input_resource_id' : refined_resource_key, 
                'input_qty' : list(refined_resource_value['Requirements']['Resources'].values())[0],
                'duration' : refined_resource_value['Duration'],
                'credits' : refined_resource_value['Requirements']['Credits']}
    refinery_main_requirements_df = refinery_main_requirements_df.append(line_item, ignore_index = True)

refinery_main_requirements_df['input_resource_id'] = refinery_main_requirements_df['input_resource_id'].astype(int)
refinery_main_requirements_df.set_index('input_resource_id')
    
refinery_outputs_df = pd.DataFrame()

for refined_resource_key, refined_resource_value in overall_data_dict['schemes']['Bases']['Actions']['2']['1'].items():
    if len(refined_resource_value['Receipt']) > 0:
        # Start at the number of resources to define each row in our entry
        for key, value in refined_resource_value['Receipt'].items():
            line_item = {'input_resource_id' : refined_resource_key, 
                        'output_resource_id' : key, 
                        'min' : value['min'], 
                        'max' : value['max']}
            refinery_outputs_df = refinery_outputs_df.append(line_item, ignore_index = True)
            
refinery_outputs_df['input_resource_id'] = refinery_outputs_df['input_resource_id'].astype(int)
refinery_outputs_df['output_resource_id'] = refinery_outputs_df['output_resource_id'].astype(int)
refinery_outputs_df = refinery_outputs_df.set_index('input_resource_id')

# Sample Usage:
# What happens if I refine Scandium ore?
#
# First - what are the requirements?
# resources_df.loc[resources_df['code'] == 'SOo23'].join(refinery_main_requirements_df)
# >>id	code	name	type	group	color	volume	credits	duration	input_qty
# 126	SOo23	Scandium ore	Ore	Metal	#85a1bb	1	380.0	18000.0	10.0

# Second - what comes out?
# resources_df.loc[resources_df['code'] == 'SOo23'].join(refinery_outputs_df).set_index('output_resource_id').join(resources_df, rsuffix = '_out')
# >>output_resource_id		code	name	type	group	color	volume	max	min	code_out	name_out	type_out	group_out	color_out	volume_out	
# 58	SOo23	Scandium ore	Ore	Metal	#85a1bb	1	5.0	4.0	STm58	Scandium	Material	Metal	#85a1bb	1
# 96	SOo23	Scandium ore	Ore	Metal	#85a1bb	1	1.0	1.0	RmCO2	Regular CO2	Material	Side	#999999	1
# 99	SOo23	Scandium ore	Ore	Metal	#85a1bb	1	1.0	1.0	PDm1	Planetary Dust	Material	Side	#999999	1



# Finally - dump all these to csv:
resources_df.to_csv('resources.csv')
components_df.to_csv('components.csv')
component_resource_requirements_df.to_csv('component_resource_requirements.csv')
component_main_requirements_df.to_csv('component_main_requirements.csv')
blueprint_component_requirements_df.to_csv('blueprint_component_requirements.csv')
mining_requirements_df.to_csv('mining_requirements.csv')
refinery_main_requirements_df.to_csv('refinery_main_requirements.csv')
refinery_outputs_df.to_csv('refinery_outputs.csv')