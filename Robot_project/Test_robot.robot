*** Settings ***
Library    OperatingSystem
Library    Collections

*** Test Cases ***
Check Application Lifespan
    ${yaml_content}=    Get File    output.yml
    Log    ${yaml_content}
    ${parsed_yaml}=    Evaluate    yaml.loads($yaml_content) yaml
    Log Many  \n%${parsed_yaml}
    FOR    ${application}    IN    @{parsed_yaml}
        Log Application: ${application}
        ${details}=    Get From Dictionary    ${parsed_yaml}    ${application}
        FOR    ${key}  ${value}   IN    ${details}
            Log  ${key}: ${value}
        END
    END
  #  ${total_apps}    Get Length    ${data}
  #  ${threshold}    Evaluate    round(${total_apps} * 0.75)
 #   ${failed_apps}    Create List
 #   ${passed_apps}    Create List
 #   FOR    ${app_name}    IN    @{data.keys()}
 #       ${lifespan}=    Convert To Number    ${data['${app_name}']['lifespan']}
 #       Run Keyword If    ${lifespan} > 30    Append To List    ${passed_apps}    ${app_name}
 #       Run Keyword If    ${lifespan} <= 30    Append To List    ${failed_apps}    ${app_name}
 #   END
 #   Run Keyword If    Length Od    ${failed_apps}    >    ${threshold}    Log    ${failed_apps] applications have a lifespan greater than 30 sec
 #   ...    WARN
 #   ...    ELSE    Log    Test Passed




