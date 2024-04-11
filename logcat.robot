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
${filename}    output.yml


*** Keywords ***
OUTPUT APPDATA TO FILE
    [Arguments]     ${filename}    ${path}    ${start_time}    ${stop_time}     ${lifespans}
     ${applications}=    Create List    application1    application2    application3    application4     application5     application6
     ${out}=    Set Variable    applications:\n
     Append To File    ${filename}   ${out}
     FOR    ${a}    IN RANGE    0    6
        ${out0}=    Set Variable    \t- ${applications}[${a}]:\n
        ${out1}=    Set Variable    \t\t\t- path:${path}[${a}]\n
        ${out2}=    Set Variable    \t\t\t- start_time: ${start_time}[${a}]\n
        ${out3}=    Set Variable    \t\t\t- stop_time: ${stop_time}[${a}]\n
        ${out4}=    Set Variable    \t\t\t- lifespan: ${lifespans}[${a}]\n
        FOR    ${i}    IN RANGE    0    5
                Append To File    ${filename}   ${out${i}}
        END
     END
FILTERED LINES
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
CREATE APPLICATIONS DICTIONARY
    [Arguments]    ${paths}    ${start_times}    ${stop_times}    ${lifespans}
    ${applications}=    Create Dictionary
    ${length}=    Get Length    ${paths}
    FOR    ${index}    IN RANGE    0    ${length}
        ${application}=    Create Dictionary    path=${paths}[${index}]    time start=${start_times}[${index}]    time stop=${stop_times}[${index}]    lifespan=${lifespans}[${index}]
        Set To Dictionary    ${applications}    aplication${index+1}=${application}
    END
    RETURN    ${applications}
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
*** Test Cases ***
Analyze Lifespan of Android Apps
    ${path}    ${start_time}    ${stop_time}=    FILTERED LINES    ${log_file_path}
    Log To Console    Start_time:${start_time}
    Log To Console    Stop_time:${stop_time}
    ${diff}=    GET LIFESPAN LiST   ${start_time}    ${stop_time}
    ${dict}=    CREATE APPLICATIONS DICTIONARY    ${path}    ${start_time}    ${stop_time}    ${diff}
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
    OUTPUT APPDATA TO FILE    ${filename}    ${path}    ${start_time}    ${stop_time}    ${diff}
    [Teardown]    Run    echo"" > ${output_file_path}