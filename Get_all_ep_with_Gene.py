import requests
import json
def get_all_gene_ep(name):
    url = f'https://rickandmortyapi.com/api/character/?name={name}'
    response = requests.get(url)
    json_resp = response.json()
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_resp}")
    episode_list=[]
    for char in json_resp["results"]:
        if char["name"] == name:
            ep=char["episode"]
            episode_list.append(ep)
            location= char["location"]["name"]
            break
    return episode_list,location
ep, location = get_all_gene_ep("Gene")
print(f"All episodes whith Gene are :{ep[0][0]}, {ep[0][1]}\nGene location is : {location}")