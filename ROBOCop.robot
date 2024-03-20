*** Variables ***

${kw_file}=    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/ccs2/RELIABILITY/KW.txt
${path_file}=    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/ccs2/RELIABILITY/patch.txt
${path1}=    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/ccs2/hlk_common/system.robot
${path2}=    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/ccs2/hlk_common/Tools/logs.robot
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
Resource          ../hlk_common/IVI/hmi.robot
Resource          ../hlk_common/IVI/filesystem.robot
Resource          ../hlk_common/IVI/Connectivity/wifi.robot
Resource          ../hlk_common/Tools/logs.robot
Resource          ../hlk_common/Vehicle/DOIP/doip.robot
Resource          ../hlk_common/system.robot
Resource          ../hlk_common/Vehicle/MQTT/mqtt_remote_services.robot
Resource          ../hlk_common/IVI/new_hmi.robot
Resource          ../hlk_common/Enabler/reliability.robot
Resource          ../hlk_common/power_supply.robot
Resource          ../hlk_common/IVC/ivc_commands.robot
Resource          ../hlk_common/Vehicle/CAN/can_remote_services.robot


*** Keywords ***
READ KW FROM CONTENT IN PATH
    [Arguments]    ${kw_name}    ${path}
    FOR    ${element}    IN    @{path}
        ${list}=    Create List
        ${kw}=    Set Variable    ${kw_name}
        ${content}=    Get File    ${element}
        ${lines}=    Split To Lines    ${content}
        ${found}=    Create List
        ${line}=    Get Index From List    ${lines}    ${kw}
        ${mes}=    Set Variable    ${EMPTY}
        ${mes1}=    Set Variable    ${EMPTY}
        IF    '${line}' == '-1'
            Log To Console    ${kw} not in ${element}
            ${mes1}=    Set Variable   ${kw} not in ${element} Please define it
        ELSE
            ${line_before}=   Evaluate    ${line}-1
            ${line_after}=    Evaluate    ${line}+1
            ${prev_line}=    Set Variable    ${lines}[${line_before}]
            ${next_line}=    Set Variable    ${lines}[${line_after}]
            ${strip}=    Split String    ${lines}[${line_after}]
            IF    "${prev_line}" == "" and ['${strip}[0]' == '[Arguments]' or '${strip}[0]' == '[Documentation]' or '${strip}[0]' == 'Log']
                ${mes}=    Set Variable    The kw ${kw} is correctly defined in ${element}
                #Log To Console   The kw ${kw} is correctly defined in ${element} because previous line is empty and second starts with ${strip}[0]
            ELSE
                Log To Console    Kw definition's conditions are not ok
            END
        END
    END
    Log To Console    message${mes}${mes1}
GET KW SECTION FROM FILE
    [Arguments]    ${lines}
      ${start_index}=    Get Index From List    ${lines}    *** Keywords ***
      ${stop_index}=    Get Index From List    ${lines}    TEARDOWN_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
      #${stop_index}=    Evaluate    ${start_index} + 13
      ${sublist}=    Create List
      FOR    ${index}    IN RANGE    ${start_index}    ${stop_index}
          Append To List    ${sublist}    ${lines}[${index}]
      END
      ${kw_list}=    Create_list
      FOR    ${index}    IN RANGE    2    10
          ${var_${index}} =    Set Variable    ${sublist}[${index}]
          ${kw}=    Evaluate    "${var_${index}.split()[0]} ${var_${index}.split()[1]} ${var_${index}.split()[2]} "
          Append To List    ${kw_list}    ${kw}
      END
      FOR    ${ind}    IN RANGE    10    13
        ${var_${ind}} =    Set Variable    ${sublist}[${ind}]
        ${kw1}=    Evaluate    "${var_${ind}.split()[5]} ${var_${ind}.split()[6]} ${var_${ind}.split()[7]} ${var_${ind}.split()[8]}"
        #Log To Console    string: ${kw1}
        Append To List    ${kw_list}    ${kw1}
      END
      RETURN    ${kw_list}
GET PATH SECTION FROM FILE
    [Arguments]   ${lines}
    ${sec}=    Set Variable    Resource
    @{match_elements}=    Evaluate    [elem for elem in ${lines} if '${sec}' in elem]
    ${result}=    Create List
    FOR    ${element}    IN    @{match_elements}
        ${substring}=    Get Substring    ${element}     10
        Append To List    ${result}    ${substring}
        ${list_no_space}=    Create List
        FOR    ${elem}    IN    @{result}
            ${no_space}=    Replace String    ${elem}    ${SPACE}    ${EMPTY}
            Append To List    ${list_no_space}   ${no_space}
        END
    END
    [Return]   ${list_no_space}
*** Test Cases ***
Check Keywords Defined
    [Documentation]    Check if all Kw are defined in the resources
    [Tags]    Setup
    ${content}=    Get File    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/ccs2/RELIABILITY/TC_SWQUAL_CCS2_RELIABILITY_B2B_PA.robot
    #Log To Console    message:${content}
    ${line_list}=    Split String    ${content}    ${\n}
    #Log To Console    lista cea mare:${line_list}
    ${kw_lis}=    GET KW SECTION FROM FILE    ${line_list}
    ${path_list}=    GET PATH SECTION FROM FILE    ${line_list}
    ${list}=    Create List
    ${mea}=    READ KW FROM CONTENT IN PATH     START TEST CASE    ${path_list}
    ${mi}=    READ KW FROM CONTENT IN PATH     CHECK VIN CONFIG ON   ${path_list}
    #${message2}=    READ KW FROM CONTENT IN PATH     START LOGCAT MONITOR    ${path_list}
    #${message3}=    READ KW FROM CONTENT IN PATH     START DLT MONITOR    ${path_list}
    #${message4}=    READ KW FROM CONTENT IN PATH     CHECK VIN AND PART ASSOCIATION    ${path_list}
    #${message5}=    READ KW FROM CONTENT IN PATH     CHECK VIN CONFIG ON    ${path_list}
    #${message6}=    READ KW FROM CONTENT IN PATH     SET PROP APLOG    ${path_list}





