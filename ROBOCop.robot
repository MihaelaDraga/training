*** Variables ***

${output_file_path}    /home/draga/PycharmProjects/pythonProject/RobotFramework/TestCases/Robot_tests/training/Robot_project/ccs2/RELIABILITY/imposters.robot
${filename}    imposters.robot
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
SEARCH KW IN PATH
    [Arguments]    ${filename}    ${kw_name}    ${path_list}
    ${list}=    Create List
    ${list1}=    Create List
    ${final}=    Create List
    FOR    ${path}    IN    @{path_list}
        ${content}=    Get File    ${path}
        ${lines}=    Split String    ${content}    ${\n}
        ${index}=    Get Index From List    ${lines}    ${kw_name}
        IF    '${index}' != '-1'
            ${line_before}=   Evaluate    ${index}-1
            ${line_after}=    Evaluate    ${index}+1
            ${prev_line}=    Set Variable    ${lines}[${line_before}]
            ${next_line}=    Set Variable    ${lines}[${line_after}]
            ${strip}=    Split String    ${lines}[${line_after}]
            ${flag}=    Set Variable    ${False}
            IF    "${prev_line}" == "" and ('${strip}[0]' == '[Arguments]' or '${strip}[0]' == '[Documentation]' or '${strip}[0]' == 'Log')
                Log To Console    ${kw_name} was found at ${index} in ${path}
                Append To List    ${list}    ${index}    ${path}
            ELSE
                Log To Console    ${kw_name} definition's conditions are not ok.Plese define correct the KW in ${path}
                Append To List    ${list}    ${index}    ${path}
            END
            Return From Keyword
        ELSE
            ${flag}=    Set Variable    ${True}
            ${var}=    Set Variable    ${kw_name}
        END
    END
    IF    '${flag}' == '${True}'
        Log To Console    ${kw_name} not found in other path
        ${out}=    Set Variable    <${var}>\n\t[Arguments] \${foo}\n\tKeyword not defined,waiting for implementation\n
        Append To File    ${filename}   ${out}
    ELSE
        Log To Console    Not here
    END
    Log To Console    ${var}
    Log To Console    ${list}
GET KW SECTION FROM FILE
    [Arguments]    ${lines}
      ${start_index}=    Get Index From List    ${lines}    *** Keywords ***
      ${stop_index}=    Get Index From List    ${lines}    TEARDOWN_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
      ${sublist}=    Create List
      FOR    ${index}    IN RANGE    ${start_index}    ${stop_index}
          Append To List    ${sublist}    ${lines}[${index}]
      END
      ${kw_list}=    Create_list
      FOR    ${index}    IN RANGE    2    6
          ${var_${index}} =    Set Variable    ${sublist}[${index}]
          ${kw}=    Evaluate    "${var_${index}.split()[0]} ${var_${index}.split()[1]} ${var_${index}.split()[2]} "
          Append To List    ${kw_list}    ${kw}
      END
      ${var6}=    Set Variable    ${sublist}[6]
      ${var7}=    Set Variable    ${sublist}[7]
      ${var8}=    Set Variable    ${sublist}[8]
      ${var9}=    Set Variable    ${sublist}[9]
      ${var10}=    Set Variable    ${sublist}[10]
      ${var11}=    Set Variable    ${sublist}[11]
      ${var12}=    Set Variable    ${sublist}[12]

      ${kw6}=    Evaluate    "${var6.split()[0]} ${var6.split()[1]} ${var6.split()[2]} ${var6.split()[3]} ${var6.split()[4]}"
      ${kw7}=    Evaluate    "${var7.split()[0]} ${var7.split()[1]} ${var7.split()[2]} ${var7.split()[3]}"
      ${kw8}=    Evaluate    "${var8.split()[0]} ${var8.split()[1]} ${var8.split()[2]} ${var8.split()[3]} ${var8.split()[4]} ${var8.split()[5]} ${var8.split()[6]}"
      ${kw9}=    Evaluate    "${var9.split()[0]} ${var9.split()[1]} ${var9.split()[2]}"
      ${kw10}=    Evaluate    "${var10.split()[5]} ${var10.split()[6]} ${var10.split()[7]} ${var10.split()[8]}"
      ${kw11}=    Evaluate    "${var11.split()[5]} ${var11.split()[6]} ${var11.split()[7]}"
      ${kw12}=    Evaluate    "${var12.split()[5]} ${var12.split()[6]} ${var12.split()[7]} ${var12.split()[8]}"
      FOR    ${index}    IN RANGE    6    13
          Append To List    ${kw_list}    ${kw${index}}
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
    RETURN    ${list_no_space}
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
    ${kw}=    Create List    START TEST CASE    SAVE CANDUMP LOGS    START LOGCAT MONITOR    CHECK VIN AND PART ASSOCIATION
    #Log To Console    message:${kw_lis}
    ${kw}=    Create List    START TEST CASE    SAVE CANDUMP LOGS    CHECK VIN AND PART ASSOCIATION    CHECK VIN CONFIG ON
    FOR    ${element}    IN    @{kw}
        SEARCH KW IN PATH    ${filename}    ${element}    ${path_list}

    END
    #SEARCH KW IN PATH    ${filename}    START TEST CASE    ${path_list}
