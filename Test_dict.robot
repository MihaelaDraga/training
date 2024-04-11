*** Settings ***
Library    OperatingSystem
Library    Collections
Library    DateTime
Library    String
Library    yaml
Library    json
Library    Telnet
Library    Process
Library    SeleniumLibrary


*** Variables ***
${log_file_path}    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/logcat_application.txt
${output_file_path}    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/output.yml
${output_file}    output.yml
*** Keywords ***
Filtered Lines
    [Arguments]    ${file_path}
    ${file}=    Get File    ${log_file_path}
    ${start_lines}=    Get Lines Containing String    ${file}    ActivityTaskManager: START u0
    ${start_list}=    Split String    ${start_lines}    ${\n}
    ${timestamp}=    Create List
    ${cmp_start_list}=    Create List
    FOR    ${line}    IN    @{start_list}
        ${time}=    Split String    ${line}    ${SPACE}
        ${cmp_val}=    Evaluate    [x.split('cmp=')[1].split('/')[0] for x in "${line}".split(' ') if 'cmp=' in x]
        Append To List    ${timestamp}   ${time}[1]
        Append To List    ${cmp_start_list}    ${cmp_val}
    END
    ${stop_lines}=    Get Lines Containing String    ${file}    Layer: Destroyed ActivityRecord
    ${stop_list}=    Split String    ${stop_lines}    ${\n}
    ${timestamp_stop}=    Create List
    FOR    ${item}    IN    @{cmp_start_list}
        ${content}=    Evaluate    "${item[0].replace('[','').replace(']','')}"
        FOR    ${line}    IN    @{stop_list}
            IF    '${content}' in '${line}'
                ${time}=    Split String    ${line}    ${SPACE}
                Append To List    ${timestamp_stop}    ${time}[1]
            END
        END
    END
    RETURN    ${cmp_start_list}    ${timestamp}    ${timestamp_stop}
Fetch Time
    [Arguments]  ${line}
    ${time}=   Get Substring    ${line}    6    18
    RETURN    ${time}
Output App Data To File
    [Arguments]    ${data}    ${filename}
    ${output}=    Set Variable    applications:\n
    ${index}=    Set Variable    1
    FOR    ${app}    IN    @{data}
        ${package}=    Set Variable    ${app.get('package','N/A')}
        ${start_time}=    Set Variable    ${app.get('start_time')}
        ${stop_time}=    Set Variable    ${app.get('stop_time')}
        ${lifespan}=    Set Variable    ${app.get('lifespan','N/A')}

        ${app_output}=    Set Variable
        ...  -application_${index}\n
        ...  -app_path: ${package}\n
        ...  -start_time: ${start_time}\n
        ...  -stop_time: ${stop_time}\n
        ...  -lifespan: ${lifespan}\n

        ${output}=    Set Variable  ${output}${app_output}\n
        ${index}=    Evaluate    ${index}+1
    END
    Create File    ${filename}    ${output}
CREATE APPLICATIONS DICTIONARY
    [Arguments]    ${paths}    ${start_times}    ${stop_times}    ${lifespans}
    ${applications}=    Create Dictionary
    ${length}=    Get Length    ${paths}
    FOR    ${index}    IN RANGE    0    ${length}
        ${application}=    Create Dictionary    path=${paths}[${index}]    time start=${start_times}[${index}]    time stop=${stop_times}[${index}]    lifespan=${lifespans}[${index}]
        #Append To List    ${applications}["applications"]    ${application}
        Set To Dictionary    ${applications}    aplication${index+1}=${application}
    END
    RETURN    ${applications}
WRITE DICTIONARY TO YAML
    [Arguments]    ${file}    ${dictionary}
    ${dict_string}=    CONVERT DICTIONARY TO JSON    ${dictionary}
    Create File    ${file}    ${dict_string}
CONVERT DICTIONARY TO JSON
    [Arguments]    ${dictionary}
    ${json_string}=    Set Variable    {
    FOR    ${key}    IN    @{dictionary}
        ${value}=    Get From Dictionary    ${dictionary}    ${key}    default
        ${json_string}=    Set Variable    ${json_string}"${key}": ${value},    ${json_string}=    Set Variable    ${json_string}[0:-1]    ${json_string}=    Set Variable    ${json_string}}
    END
    RETURN    ${json_string}
WRITE TO FILE
    [Arguments]    ${file_path}    ${content}
    ${file}=    Set Variable    ${file_path}
    ${file}=    Evaluate    open($file, 'w')
    Evaluate    $file.write($content)
    Evaluate    $file.close()

GET LIFESPAN LIST
    [Arguments]    ${start_times}    ${stop_times}
    ${lifespans}=    Create List
    ${lengh}=    Get Length    ${start_times}
    FOR    ${index}    IN RANGE    ${lengh}
        ${start_time}=    Convert Time    ${start_times}[${index}]
        ${stop_time}=    Convert Time    ${stop_times}[${index}]
        ${difference}=    Evaluate    ${stop_time} - ${start_time}
        ${sec}=    CONVERT SECONDS TO TIME FORMAT    ${difference}
        Append To List    ${lifespans}    ${sec}
    END
    RETURN    ${lifespans}
CONVERT SECONDS TO TIME FORMAT
    [Arguments]    ${seconds}
    ${hours}=   Evaluate    int(${seconds} / 3600)
    ${minutes}=    Evaluate    int((${seconds} % 3600)/60)
    ${seconds_remainder}=    Evaluate    round(${seconds} % 60, 3)
    ${time}=    Set Variable    ${seconds_remainder}
    RETURN    ${time}
CREATE YAML CONTENT
    [Arguments]    ${dictionary}
    ${yaml}=    Catenate
    ...    "- application1:\n"
    ...    "- path:['com.sec.android.app.camera']"
    ...    "- time start:17:56:07.504"
    ...    "- time stop: 17:56:30.882"
    ...    "- lifespan: 23.378"
    ...    "- application2:\n"
    ...    "- path:['com.netflix.mediaclient']"
    ...    "- time start:17:56:29.534"
    ...    "- time stop: 17:57:00.006"
    ...    "- lifespan: 30.472"
    ...    "- application3:\n"
    ...    "- path:['com.android.vending']"
    ...    "- time start:17:56:33.783"
    ...    "- time stop: 17:56:49.245"
    ...    "- lifespan: 15.462"
    ...    "- application4:\n"
    ...    "- path:['com.spotify.music']"
    ...    "- time start:17:56:40.793"
    ...    "- time stop: 17:56:58.802"
    ...    "- lifespan: 18.009"
    ...    "- application5:\n"
    ...    "- path:['com.sec.android.app.popupcalculator']"
    ...    "- time start:17:56:59.524"
    ...    "- time stop: 17:57:25.200"
    ...    "- lifespan: 25.676"
    ...    "- application6:\n"
    ...    "- path:['com.sec.android.app.clockpackage']"
    ...    "- time start:17:57:16.608"
    ...    "- time stop: 17:57:59.906"
    ...    "- lifespan: 43.298"
    RETURN    ${yaml}
*** Test Cases ***
Analyze Lifespan of Android Apps
    ${path}    ${start_time}    ${stop_time}=    Filtered Lines    ${log_file_path}
    Log To Console    Start_time:${start_time}
    Log To Console    Stop_time:${stop_time}
    ${diff}=    GET LIFESPAN LiST   ${start_time}    ${stop_time}
    ${dict}=    CREATE APPLICATIONS DICTIONARY    ${path}    ${start_time}    ${stop_time}    ${diff}
    Log To Console    Dictionary: ${dict}
    ${total_apps}=    Get Length    ${dict}
    ${less_than_30}=    Set Variable    0
    FOR    ${app}    IN    @{dict}
        ${lifespan}=    Get From Dictionary     ${dict}[${app}]     lifespan    default
        IF    ${lifespan} < 30
          ${less_than_30}=    Evaluate  ${less_than_30}+1
        END
        Run Keyword If    ${lifespan} > 30    Log To Console    Application ${app} has a lifespan more than 30 s
    END
    ${percentage}=    Evaluate    ${total_apps} * 0.75
    ${round_percentage}=  Evaluate    round(${percentage})
    Run Keyword If    ${less_than_30} == ${round_percentage}
    ...    Log To Console    The test is PASS because the "lifespan"of 75% of applications is less than 30
    ...  ELSE    Fail    Condition is false
    ${yaml}=    CREATE YAML CONTENT    ${dict}
     ${python_code}=    Catenate
     ...    ...    import yaml\n
     ...    ...    with open(${output_file_path}, 'w') as file:\n
     ...    ...    yaml.safe_dump(${dict}, file, default_flow_style=False)\n
     Log To Console    python code: ${python_code}
     Run Process    python -c "${python_code}"
     ${file_exists}=    File Should Exist    ${output_file_path}
     Log To Console    sadfgh${file_exists}
     #Execute Javascript    var fs = require('fs); fs.writeFileSync('${output_file}', '${yaml}')