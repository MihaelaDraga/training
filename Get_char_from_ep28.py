import requests
import json
def get_char_from_ep_28():
    url = 'https://rickandmortyapi.com/api/episode/28'
    response = requests.get(url)
    json_resp = response.json()
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_resp}")
    list=[]
    for char in json_resp["characters"]:
        url1 = f'{char}'
        response = requests.get(url1)
        json_resp = response.json()
        list.append(json_resp['name'])
    rick_names= [name for name in list if 'Rick' in name]
    print("All characters from ep 28 with Rick name are:",rick_names)
get_char_from_ep_28()