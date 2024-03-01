# Copyright (c) 2022, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Launching B2B WAKEUP SLEEP_001 on CCS2 platform
...               This test will check in loop the suspend resume on CCS2. Then, some checks are done to verify IP connection and MQTT connection of IVC, and boot reason and the ui is not frozen for IVI.
...               Usage: robot -v loop_ccs2_connectivity001:XX  -v kpi_ccs2_wakeup001:XX ccs2/RELIABILITY/TC_SWQUAL_CCS2_RELIABILITY_B2B_CONNECTIVITY_001.robot
...               Variable definition: loop => number of campaign iteration
...               Variable definition: kpi => passrate expected
...               Variable definition: bench_power_type => type of power supply (domino / relaycard / E3648@debug / E3642@debug / A66319@debug / keithley@debug / A66319@pnp / deviceRigol)

Test Setup        SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_CONNECTIVITY_001
Test Teardown     TEARDOWN_TC_SWQUAL_CCS2_RELIABILITY_B2B_CONNECTIVITY_001

Resource          ../hlk_common/IVI/hmi.robot
Resource          ../hlk_common/IVI/filesystem.robot
Resource          ../hlk_common/IVI/Connectivity/wifi.robot
Resource          ../hlk_common/Tools/artifactory.robot
Resource          ../hlk_common/Vehicle/DOIP/doip.robot
Resource          ../hlk_common/system.robot
Resource          ../hlk_common/IVI/network.robot
Resource          ../hlk_common/Vehicle/MQTT/mqtt_remote_services.robot
Resource          ../hlk_common/IVI/new_hmi.robot
Resource          ../hlk_common/Enabler/reliability.robot
Resource          ../hlk_common/power_supply.robot
Resource          ../hlk_common/IVC/cs_dut_dialog.robot
Resource          ../hlk_common/Vehicle/CAN/can_remote_services.robot

Library           String
Library           DateTime
Library           Process
Library           rfw_services.wicket.DateLib
Library           rfw_services.wicket.LogsLib
Library           rfw_libraries.logmon.DltMonitor

*** Variables ***
${loop_ccs2_connectivity001}    100
${artifactory_logs_folder}       ccs2_connected_platform/SWL/Temp/DEBUG/SWEET400
${enable_aplog}    yes
${enable_logs}    yes
${dlt_conf_file}       dlt_logstorage.conf
${url_path}    matrix/artifacts/reliability/DLT_conf/Connectivity/
${kpi_connectivity}    85
${debug}    True
${bench_can_logs}      True
@{list_iterations_verdict_status}
@{list_iterations_no_verdict_status}
@{iterations_time}
${artifactory_destination}    ccs2_connected_platform/SWL/Reliability/
${stoffdata}    False
${stdrx}    False
${stoff}    False
${reset_budget}    0
${count_stdrx}    0
${count_stoff}    0
${count_stoffdata}    0
${TC_folder}    RELIABILITY
${budget_reseted}    0
${setup_fail}    True

*** Keywords ***
SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_CONNECTIVITY_001
    Run Keyword if    "${console_logs}" == "yes"     Log    ${TEST NAME} has started with ${loop_ccs2_connectivity001} loops    WARN
    START TEST CASE
    START LOGCAT MONITOR    ${ivi_adb_id}    regex=${FALSE}
    START DLT MONITOR
    SAVE CANDUMP LOGS    /rhw/logmon_logs/candump/setup    setup
    REMOVE IVI APLOG    ${ivi_adb_id}
    REMOVE IVI DROPBOX CRASHES    ${ivi_adb_id}
    DELETE DLT LOGS
    DOWNLOAD ARTIFACTORY FILE    ${url_path}${dlt_conf_file}    ${FALSE}
    SYSTEM SEND FILE TO DEVICE        ${dlt_conf_file}    /mnt/mmc/logs/${dlt_conf_file}
    Run Keyword if    "${console_logs}" == "yes"     Log    **** ENABLE IVI DEBUG LOGS ****    console=yes
    Run Keyword if    "${enable_aplog}" == "yes"    SET PROP APLOG    ${ivi_adb_id}
    Run Keyword if    "${enable_logs}" == "yes"    Run Keyword And Ignore Error     ENABLE IVI DEBUG LOGS      ${ivi_adb_id}    ${current_tc_name}    ${micom_port}    ${bootloader_port}    ${log_to_save}
    SET IVI IP TABLES FOR IVC SSH CONNECTION
    CHECKSET WIFI STATUS    ${ivi_adb_id}    off
    ${loop_folder} =    Set variable   /rhw/debug_logs/${current_tc_name}/setup
    Create Directory    ${loop_folder}
    RETRIEVE IVI APLOG    ${loop_folder}
    RETRIEVE IVI DMESG     ${ivi_adb_id}    setup
    SAVE IVI DROPBOX CRASHES    ${ivi_adb_id}
    SYSTEM GET FILE FROM DEVICE    /mnt/mmc/logs/    ${loop_folder}
    CHECKSET SLEEP CONFIGURATION    Stoffdata
    DO BCM STANDBY    150
    LAUNCH INITIAL SEQUENCE      ${start_can_sequence}
    CHECK IVC BOOT COMPLETED
    CHECK IVI MQTT CONNECTION STATUS
    RESET BUDGETS
    DELETE DLT LOGS

TEARDOWN_TC_SWQUAL_CCS2_RELIABILITY_B2B_CONNECTIVITY_001
    Run Keyword If   "${setup_fail}"=="True"    Run Keyword And Warn On Failure    RETRIEVE LOGS FROM SETUP
    Run Keyword And Warn On Failure    RETRIEVE IVI ECS LOGS
    Run Keyword And Ignore Error     WRITE IVC DRX PARAMETERS    ${can_flag}    &{IVC_initial_config}
    STOP LOGCAT MONITOR
    Run Keyword And Ignore Error    STOP DLT MONITOR
    ${week_id} =    GET CURRENT WEEK
    Run Keyword And Ignore Error    STOP TEST CASE
    ZIP DLT    ${current_tc_name}
    Run Keyword if    "${push_artifactory}" == "yes"    Run Keyword And Continue On Failure    PUSH FILES TO ARTIFACTORY    /rhw/debug_logs/${current_tc_name}.zip    ${artifactory_destination}WW${week_id}_IVI_${ivi_build_id}_IVC_${ivc_build_id}/

*** Test Cases ***
TC_SWQUAL_CCS2_RELIABILITY_B2B_CONNECTIVITY_001
    ${number_of_iterations} =    Evaluate    ${loop_ccs2_connectivity001} + 1
    Set Test Variable    ${count_stdrx}
    Set Test Variable    ${count_stoff}
    Set Test Variable    ${count_stoffdata}
    FOR    ${var}    IN RANGE    1    ${number_of_iterations}
        START RELIABILITY LOOP    ${status_list_verdict}    ${status_list_no_verdict}    ${var}
        Run Keyword if    "${console_logs}" == "yes"     Log    **** DO BCM STANDBY ****    console=yes
        CLOSE SSH SESSION
        IF    "${var}" == "1"
            ${stoffdata} =  Set Variable    True
            Set Test Variable    ${stoffdata}
            ${stoff} =  Set Variable    False
            Set Test Variable    ${stoff}
        END
        CHECK KEYWORD STATUS    DO BCM STANDBY      no_verdict    ${status_list_no_verdict}    ${var}    150
        Run Keyword if    "${console_logs}" == "yes"     Log    **** SEND VEHICLE WAKEUP COMMAND ****    console=yes
        CHECK KEYWORD STATUS    LAUNCH INITIAL SEQUENCE      no_verdict    ${status_list_no_verdict}    ${var}    ${start_can_sequence}
        Run Keyword if    "${console_logs}" == "yes"     Log    **** CHECK IVI BOOTED ****    console=yes
        CHECK KEYWORD STATUS    CHECK IVI BOOT COMPLETED    verdict    ${status_list_verdict}    ${var}    booted    120    ${TC_folder}
        INJECT LOGCAT MESSAGE    ccar    IVI_BOOT_COMPLETED
        Run Keyword if    "${console_logs}" == "yes"     Log    **** CHECK IVC BOOTED ****    console=yes
        CHECK KEYWORD STATUS    CHECK VEHICLE SIGNAL    verdict    ${status_list_verdict}    ${var}    IVC_FOTA_Status_v2    0x0    timeout=180
        Sleep    20s
        Run Keyword if    "${console_logs}" == "yes"     Log    **** CHECK IVC BOOTED ****    console=yes
	    CHECK KEYWORD STATUS    CHECK IVC BOOT COMPLETED    verdict    ${status_list_verdict}    ${var}   180    True
	    INJECT LOGCAT MESSAGE    ccar    IVC_BOOT_COMPLETED
        ${value_verdict} =    Run Keyword And Continue On Failure    CHECK KERNEL PANIC    ${current_tc_name}    ${var}    ${ivi_adb_id}
        Run Keyword if     "${value_verdict}" == "False"     Log     Loop ${var} failed: kernel_panic    WARN
        CHECK KEYWORD STATUS    CHECK AND RETRIEVE BOOT MODE    verdict    ${status_list_verdict}    ${var}    ecs
        SAVE CANDUMP LOGS    /rhw/logmon_logs/candump/loop_${var}    ${var}
        CHECK KEYWORD STATUS    CHECK IVC CONNECTIVITY    verdict    ${status_list_verdict}    ${var}
        INJECT LOGCAT MESSAGE    ccar    IVC_CONNECTIVITY_CHECKED
        CHECK KEYWORD STATUS    CHECK IVI MQTT CONNECTION STATUS    verdict    ${status_list_verdict}    ${var}    success    4    10
        INJECT LOGCAT MESSAGE    ccar    IVI_MQTT_CONNECTION_CHECKED
        CHECK KEYWORD STATUS    CHECK IVI INTERNET    verdict    ${status_list_verdict}    ${var}
        ${reset_budget} =    Evaluate    ${var} % 15
        ${budget_reseted} =    Evaluate    ${budget_reseted} + 1
        Set Test Variable    ${budget_reseted}
        IF    "${reset_budget}" == "0"
            ${budget_reseted} =    Set Variable    0
            Set Test Variable    ${budget_reseted}
            Run Keyword if    "${console_logs}" == "yes"     Log    **** RESET BUDGETS on ${var}th loop****    console=yes
            INJECT LOGCAT MESSAGE    ccar    START_RESET_BUDGET_IVC
            CHECK KEYWORD STATUS    RESET BUDGETS    no_verdict    ${status_list_no_verdict}    ${var}
            ${stoffdata} =  Set Variable    True
            Set Test Variable    ${stoffdata}
            ${stoff} =  Set Variable    False
            Set Test Variable    ${stoff}
        END
        CHECK IVC STATE TRANSITION
        STOP ANALYZING DLT DATA
        SAVE IVI DROPBOX CRASHES    ${ivi_adb_id}
        CHECK KEYWORD STATUS    RETRIEVE IVI APLOG    no_verdict    ${status_list_no_verdict}    ${var}   ${loop_folder}
        CHECK KEYWORD STATUS    RETRIEVE IVI DMESG    no_verdict    ${status_list_no_verdict}    ${var}    ${ivi_adb_id}    ${var}
        CHECK KEYWORD STATUS    DELETE DLT LOGS    no_verdict    ${status_list_no_verdict}    ${var}
        END RELIABILITY LOOP    ${status_list_verdict}    ${status_list_no_verdict}    ${var}    ${start_time}
    END
    Run Keyword if    "${console_logs}" == "yes"     Log    **** IVC STATE REPORT FOR CONNECTIVITY TC: STOFF states:${count_stoff} STDRX states:${count_stdrx} STOFFDATA states:${count_stoffdata} out of ${var} loops ****    WARN
    CALCULATE RELIABILITY PASSRATE    ${kpi_connectivity}