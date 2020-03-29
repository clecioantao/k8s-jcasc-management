#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

# Variables
_K8S_MGMT_HELM_INSTALL_COMMAND="install"
_K8S_MGMT_HELM_UPGRADE_COMMAND="upgrade"


##########
# This function installs the persistence volume claim if needed
#
##########
function installPersistenceVolumeClaim() {
    # variables
    local __INTERNAL_PROJECT_DIRECTORY
    dialogAskForProjectDirectory __INTERNAL_PROJECT_DIRECTORY
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE

    # create new variable with full project directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${__INTERNAL_PROJECT_DIRECTORY}"

    # if pvc exists, try to install it
    if [[ -f "${__INTERNAL_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml" ]]; then
        # load the name of the PVC
        local __INTERNAL_PVC_FROM_FILE=$(grep 'name:' ${__INTERNAL_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml | awk '{print $2}' | tr -d '"')
        # check Kubernetes, which PVC for the namespace are existing
        local __INTERNAL_EXISTING_PVC_ON_K8S=$(kubectl -n ${__INTERNAL_NAMESPACE} get pvc | awk '{print $1}' | grep ${__INTERNAL_PVC_FROM_FILE})
        # predefine variable to decide if PVC has to be installed or not
        local __INTERNAL_BOOLEAN_CREATE_PVC=true

        # Because of similar names, we have to check the PVC like a list, because it can contain multiple elements
        if [[ "${__INTERNAL_EXISTING_PVC_ON_K8S}" =~ [[:space:]] ]]; then
            local array __INTERNAL_EXISTING_PVC_ON_K8S_ARRAY=(${__INTERNAL_EXISTING_PVC_ON_K8S})
            for __INTERNAL_EXISTING_PVC_ARR_ELEMENT in "${__INTERNAL_EXISTING_PVC_ON_K8S_ARRAY[@]}"
            do
                if [[ "${__INTERNAL_EXISTING_PVC_ARR_ELEMENT}" == "${__INTERNAL_PVC_FROM_FILE}" ]]; then
                    __INTERNAL_BOOLEAN_CREATE_PVC=false
                    break
                fi
            done
        else
            # Only one element was found, compare it directly
            if [[ "${__INTERNAL_EXISTING_PVC_ON_K8S}" == "${__INTERNAL_PVC_FROM_FILE}" ]]; then
                __INTERNAL_BOOLEAN_CREATE_PVC=false
            fi
        fi

        # Looks like no existing PVC was found. Lets create a new one
        if [[ "${__INTERNAL_BOOLEAN_CREATE_PVC}" == "true" ]]; then
            echo ""
            echo "  INFO: Create PVC ${__INTERNAL_PVC_FROM_FILE}..."
            echo ""
            kubectl -n ${__INTERNAL_NAMESPACE} apply -f ${__INTERNAL_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml
            # now we should wait shortly, to avoid race conditions
            sleep 1
        else
            echo ""
            echo "  INFO: PVC ${__INTERNAL_PVC_FROM_FILE} already exists..."
            echo ""
        fi
    fi
}

##########
# This function installs the Jenkins instance
#
# argument 1: INSTALL or UPGRADE (see _K8S_MGMT_COMMAND_INSTALL or _K8S_MGMT_COMMAND_UPGRADE at the arguments_utils.sh file)
##########
function installOrUpgradeJenkins() {
    ## install Jenkins to Kubernetes
    # arguments
    local ARG_INSTALL_UPGRADE_COMMAND=$1

    # validate helm command
    local __INTERNAL_HELM_COMMAND
    if [[ "${ARG_INSTALL_UPGRADE_COMMAND}" == "${_K8S_MGMT_COMMAND_INSTALL}" ]]; then
        __INTERNAL_HELM_COMMAND="${_K8S_MGMT_HELM_INSTALL_COMMAND}"
    elif [[ "${ARG_INSTALL_UPGRADE_COMMAND}" == "${_K8S_MGMT_COMMAND_UPGRADE}" ]]; then
        __INTERNAL_HELM_COMMAND="${_K8S_MGMT_HELM_UPGRADE_COMMAND}"
    else
        echo ""
        echo "  ERROR: Unknown command used! Please do not use the install_controller.sh script directly."
        echo ""
        exit 1
    fi

    # path to helm charts
    local __INTERNAL_HELM_JENKINS_PATH="./charts/jenkins-master"
    # get namespace from global variables or ask for the name
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE
    # get project directory
    local __INTERNAL_PROJECT_DIRECTORY
    dialogAskForProjectDirectory __INTERNAL_PROJECT_DIRECTORY
    # get deployment name
    local __INTERNAL_DEPLOYMENT_NAME
    dialogAskForDeploymentName __INTERNAL_DEPLOYMENT_NAME
    # get IP address of the installation
    local __INTERNAL_IP_ADDRESS
    readIpForNamespaceFromFile "${__INTERNAL_NAMESPACE}" __INTERNAL_IP_ADDRESS

    # create new variable with full project directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${__INTERNAL_PROJECT_DIRECTORY}"

    # set global variables
    if [[ ! -z "${__INTERNAL_NAMESPACE}" ]]; then
        K8S_MGMT_NAMESPACE="${__INTERNAL_NAMESPACE}"
    fi
    if [[ ! -z "${__INTERNAL_PROJECT_DIRECTORY}" ]]; then
        K8S_MGMT_PROJECT_DIRECTORY="${__INTERNAL_PROJECT_DIRECTORY}"
    fi
    if [[ ! -z "${__INTERNAL_DEPLOYMENT_NAME}" ]]; then
        K8S_MGMT_DEPLOYMENTNAME="${__INTERNAL_DEPLOYMENT_NAME}"
    fi

    # start with apply secrets to kubernetes
    echo ""
    echo "  INFO: Apply secrets..."
    echo ""
    applySecrets "${K8S_MGMT_NAMESPACE}"

    # Now lets install the PVC if it does not exist
    installPersistenceVolumeClaim

    # install or upgrade the Jenkins Helm Chart
    helm ${__INTERNAL_HELM_COMMAND} ${K8S_MGMT_DEPLOYMENTNAME} ${__INTERNAL_HELM_JENKINS_PATH} -n ${K8S_MGMT_NAMESPACE} -f ${K8S_MGMT_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
}

##########
# This function uninstalls the Jenkins instance
#
##########
function uninstallJenkins() {
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE
    local __INTERNAL_DEPLOYMENT_NAME
    dialogAskForDeploymentName __INTERNAL_DEPLOYMENT_NAME

    helm uninstall ${__INTERNAL_DEPLOYMENT_NAME} -n ${__INTERNAL_NAMESPACE}
}