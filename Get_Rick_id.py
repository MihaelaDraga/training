import requests
import json
def get_char_id(name):
    url = 'https://rickandmortyapi.com/api/character/?name=Rick Sanchez'
    response = requests.get(url)
    json_data = response.json()
    with open("api_datas.json", "w") as json_file:
        json_file.write(f"{json_data}\n" )
    if response.status_code == 200:
        char_name = response.json()
        ep_lengh_list=[]
        for char in char_name["results"]:
            lengh=len(char["episode"])
            ep_lengh_list.append(lengh)
            max_lengh=max(ep_lengh_list)
            if len(char["episode"]) == max_lengh and char["status"] == 'Alive':
                search_id = char["id"]
                break
            else:
                print("No match found")
    return search_id
name='Rick Sanchez'
id = get_char_id(name)
print(f"The id of {name} is :{id}")



