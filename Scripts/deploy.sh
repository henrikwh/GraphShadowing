#!/bin/bash
set -u -e -o pipefail


# while getopts s: flag
# do
#     case "${flag}" in
#         s) deploy=${OPTARG};;
#     esac
# done


echo "Building..."
source ./helpers.sh

basedir="$( dirname "$( readlink -f "$0" )" )"

#CONFIG_FILE="${basedir}/./config.json"
CONFIG_FILE="./temp/appSettings.local.json"

#get-value  ".webappEndpoint"

# if  [ $deploy = "web" ] || [ $deploy = "all" ]; then

#     appName="$( get-value  ".webappEndpoint" | cut -d "." -f 1)"
#     resourceGroupName="$( get-value  ".initConfig.resourceGroupName" | cut -d "." -f 1)"

#     echo "App: ${appName}"
#     echo "Resource group :${resourceGroupName}"
#     (dotnet publish "../src/SampleApp/WebAPI/WebAPI.csproj" -c DEBUG --output ./temp/publishWebapp && cd ./temp/publishWebapp && zip -r ../webApp.zip * && cd ../../ ) \
#         || echo "failed to compile" \
#             | exit 1
#     echo "Deploying webapp..."
#     az webapp deploy --resource-group "${resourceGroupName}" --name "${appName}" --src-path ./temp/webApp.zip --type zip
# fi

    appName="$( get-value  ".functionEndpoint" | cut -d "." -f 1)"
    resourceGroupName="$( get-value  ".initConfig.resourceGroupName" | cut -d "." -f 1)"

    echo "App: ${appName}"
    echo "Resource group :${resourceGroupName}"
    (dotnet publish "../ShadowFunctions/ShadowFunctions.csproj" -c DEBUG --output ./temp/publishfunc && cd ./temp/publishfunc && zip -r ../functionApp.zip * .[^.]* && cd ../../ ) \
        || echo "failed to compile" \
            | exit 1
    echo "Deploying functionapp..."
    az functionapp deployment source config-zip -g "${resourceGroupName}" -n "${appName}" --src ./temp/functionApp.zip 
    #az functionapp deployment source config-zip -g "${resourceGroupName}" -n "${appName}" --src /mnt/c/temp/pub/t.zip
