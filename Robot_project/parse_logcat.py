from datetime import datetime
import re
import os
def find_lines_between_pairs(filename,var):
    matching_lines = []
    with open (filename, 'r') as file :
        for line in file:
            if var in line:
                inside_pair = True
                matching_lines.append(line.strip())
    return matching_lines
def find_time_and_cmp_start(input_list):
    times = []
    time_pattern= re.compile(r'(\d{2}:\d{2}:\d{2}.\d{3})')
    cmp_values = []
    cmp_pattern = re.compile(r'cmp=(\S+?)/')
    for element in input_list:
        time_match=time_pattern.search(element)
        cmp_match = cmp_pattern.search(element)
        if time_match and cmp_match:
            times.append(time_match.group(1))
            cmp_values.append(cmp_match.group(1))
    return times, cmp_values
def find_time_and_cmp_stop(lista):
    secvente =[]
    cmp_pattern = re.compile(r'u0 (.*?)\}')
    times = []
    time_pattern = re.compile(r'(\d{2}:\d{2}:\d{2}.\d{3})')
    for element in lista:
        time_match = time_pattern.search(element)
        cmp_match = cmp_pattern.search(element)
        if time_match and cmp_match:
            times.append(time_match.group(1))
            secvente.append(cmp_match.group(1))
    return times, secvente
def combine_lists(list1, list2):
    pairs = list(zip(list1,list2))
    result = [list(elem) for elem in pairs]
    return  result
def search_pairs(list1,list2):
    pairs_found =[]
    result = []
    for time, application in list1:
        for index, pair in enumerate(list2):
            if application == pair[1]:
                pairs_found.append((time, list2[index]))
                break
    return pairs_found
def process_list(list):
    result = []
    for start_time, (stop_time,application) in list:
        time_start =start_time
        time_stop=stop_time
        path = application
        sequence = [element for element in application if "com." in element]
        result.append((time_start,time_stop,path))
    return result
def create_output_dict(list):
    result_dict ={}
    for start_time, stop_time, path in list:
        time_diff =calculate_time_diff(start_time,stop_time)
        #time_dif_milisec = time_diff[-6:]
        milisec = float(time_diff.split(':')[-1])

        result_dict[f"Aplication:{path[8:]}"]={
            'app_path': path,
            'ts_app_started':start_time ,
            'ts_app_stopped':stop_time,
            'lifespan':milisec

        }
    return result_dict
def calculate_time_diff(start_time,stop_time):
    start_time=datetime.strptime(start_time, '%H:%M:%S.%f')
    stop_time = datetime.strptime(stop_time, '%H:%M:%S.%f')
    diff = stop_time - start_time
    diff_formated = str(diff)
    return diff_formated
filename= "logcat.txt"
var1 = "ActivityTaskManager: START u0"
var2 = "Layer: Destroyed ActivityRecord"
v1 = find_lines_between_pairs(filename,var1)
v2= find_lines_between_pairs(filename,var2)
print(v1)
print(v2)
time_list, cmp_list=find_time_and_cmp_start(v1)
print(f"Time list is: {time_list},Cmp list is: {cmp_list}")
time_list1, cmp_list1 = find_time_and_cmp_stop(v2)
print(f"Time list is: {time_list1},Cmp list is: {cmp_list1}")
result = combine_lists(time_list,cmp_list)
print(result)
result1 = combine_lists(time_list1,cmp_list1)
print(result1)
print("Searched pairs are:",search_pairs(result,result1))
a = process_list(search_pairs(result,result1))
print(a)
b=create_output_dict(a)
print(create_output_dict(a))
current_dir = os.getcwd()
output_file_path = os.path.join(current_dir, 'output.yml')
with open(output_file_path, 'w') as f:
    for key,value in b.items():
        f.write(f"{key}:\n")
        for sub_key,sub_value in value.items():
            f.write(f"    {sub_key}: {sub_value}\n")
print("Dict has been written")