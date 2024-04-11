import requests
import json
def get_alive_chars():
    url = 'https://rickandmortyapi.com/api/location/?name=narnia'
    response = requests.get(url)
    json_resp = response.json()
    list=[]
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_resp}")
    for char in json_resp["results"]:
        residents=char["residents"]
        for res in residents:
            chars_alive=check_alive_char_in_narnia(res)
            list.append(chars_alive)
    non_empty_list=[item for sublist in list if sublist for item in sublist]
    return non_empty_list
def check_alive_char_in_narnia(url):
    response = requests.get(f'{url}')
    json_resp = response.json()
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_resp}")
    status_list=[]
    if json_resp["status"] == "Alive":
        a=json_resp["name"]
        status_list.append(f"{a}")
        print(f"{a} is Alive in Narnia")
    else:
        b=json_resp["name"]
        print(f"{b} is dead")
    return status_list
chars=get_alive_chars()
print("All Alive chars in Narnia",chars)