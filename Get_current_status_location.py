import requests
import json
def get_status_location(name):
    if name == "Rick Sanchez":
        url = f'https://rickandmortyapi.com/api/character/?name={name}'
        response = requests.get(url)
        json_resp = response.json()
        with open("api_datas.json", "w") as json_file:
            json_file.write(f"{json_resp}")
        for char in json_resp["results"]:
            ep_lengh_list = []
            lengh = len(char["episode"])
            ep_lengh_list.append(lengh)
            max_lengh = max(ep_lengh_list)
            if len(char["episode"]) == max_lengh and char["status"] == 'Alive':
                search_id = char["id"]
            if char["id"] == search_id:
                current_status=char["status"]
                location=char["location"]["name"]
                print(f"Current status of {name} is :{current_status}")
                break
    if name == "Morty Smith":
        ep_lengh_list=[]
        url = f'https://rickandmortyapi.com/api/character/?name={name}'
        response = requests.get(url)
        json_resp = response.json()
        for char in json_resp["results"]:
            lengh = len(char["episode"])
            ep_lengh_list.append(lengh)
            max_lengh = max(ep_lengh_list)
            if len(char["episode"]) == max_lengh and char["status"] == 'Alive':
                search_id = char["id"]
            if char["id"] == search_id:
                current_status = char["status"]
                location = char["location"]["name"]
                print(f"Current status of {name} is :{current_status}")
                break
    return current_status,location
name= "Rick Sanchez"
name1="Morty Smith"
current_statusR,Rick_location=get_status_location(name)
current_statusM,Morty_location=get_status_location(name1)
print(f"Rick current location is: {Rick_location} and his current status is {current_statusR}")
print(f"Morty current location is: {Morty_location} and his current status is {current_statusM}")