import requests
import json
def get_all_species(ses3_type_list):
    url = 'https://rickandmortyapi.com/api/character/'
    response = requests.get(url)
    json_resp = response.json()
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_resp}")
    list=[]
    list1=[]
    a=json_resp['info']['pages']
    for i in range(1,a,1):
        url=f'https://rickandmortyapi.com/api/character/?page={i}'
        response = requests.get(url)
        json_resp = response.json()
        for char in json_resp["results"]:
            for elem in ses3_type_list:
                if char["type"] == elem:
                    list.append(char["name"])
                    a=char["name"]
                    b=char["species"]
                    c=char["type"]
                    #print(f"{a} is species {b} and type {c}")
                else:
                    list1.append(char["name"])
    print("All season3 type names list is:",list)
        #print("This names are not in season 3,",list1)
    return list
#def create_specific_list(list):
#    unique_species = []
#    for _, species , type in list:
#        if species not in unique_species:
#            unique_species.append(species)
#    print(unique_species)
def get_season_03():
    url='https://rickandmortyapi.com/api/episode/?episode=S03'
    response = requests.get(url)
    json_resp = response.json()
    lista=[]
    flattened_list=[]
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_resp}")
    for char in json_resp["results"]:
        chars=char["characters"]
        lista.append(chars)
        flattened_list=[item for sublist in lista for item in sublist]
    filtered_list = [x for i, x in enumerate(flattened_list) if x not in flattened_list[:i]]
    return filtered_list
def get_all_season3_types(list):
    list_name_types=[]
    unique_elem_list=[]
    for elem in list:
        url = f'{elem}'
        response = requests.get(url)
        json_resp = response.json()
        list_name_types.append(json_resp["type"])
    flattened_list = [item for item in list_name_types if item]
    [unique_elem_list.append(element) for element in flattened_list if element not in unique_elem_list]
    return unique_elem_list


list=get_season_03()
ses3_type_list=get_all_season3_types(list)
print("types",ses3_type_list)
all_species=get_all_species(ses3_type_list)
