import requests
import json
def get_char_from_ep_29():
    url = 'https://rickandmortyapi.com/api/episode/29'
    response = requests.get(url)
    json_resp = response.json()
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_resp}")
    list=[]
    for char in json_resp["characters"]:
        url1 = f'{char}'
        response = requests.get(url1)
        json_resp = response.json()
        list.append((json_resp['name'],json_resp['status']))
        chars_not_alive= [pair[0] for pair in list if pair[1] != "Alive"]
    message = "Chars from ep 29 that are not Alive:"
    print(message)
    for item in chars_not_alive:
        print(f" - {item}")
get_char_from_ep_29()