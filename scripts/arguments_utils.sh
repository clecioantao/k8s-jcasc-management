#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# Global command variables
_K8S_MGMT_COMMAND_INSTALL="INSTALL"
_K8S_MGMT_COMMAND_UPGRADE="UPGRADE"
_K8S_MGMT_COMMAND_UNINSTALL="UNINSTALL"
_K8S_MGMT_COMMAND_SECRETS_ENCRYPT="SECRETS_ENCRYPT"
_K8S_MGMT_COMMAND_SECRETS_DECRYPT="SECRETS_DECRYPT"
_K8S_MGMT_COMMAND_SECRETS_APPLY="SECRETS_APPLY"
_K8S_MGMT_COMMAND_SECRETS_APPLY_TO_ALL_NAMESPACES="SECRETS_APPLY_ALL_NAMESPACES"
_K8S_MGMT_COMMAND_CREATE_PROJECT="CREATE_PROJECT"
_K8S_MGMT_COMMAND_CREATE_DEPLOYMENT_ONLY_PROJECT="CREATE_DEPLOYMENT_ONLY_PROJECT"
_K8S_MGMT_COMMAND_CREATE_JENKINS_USER_PASSWORD="CREATE_JENKINS_USER_PASSWORD"
K8S_MGMT_NO_DIALOG="false"

##########
# Functions to set the K8S_MGMT_COMMAND.
function setCommandToInstall() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_INSTALL}"
}
function setCommandToUnInstall() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_UNINSTALL}"
}
function setCommandToUpgrade() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_UPGRADE}"
}
function setCommandToSecretsEncrypt() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_ENCRYPT}"
}
function setCommandToSecretDecrypt() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_DECRYPT}"
}
function setCommandToSecretsApply() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_APPLY}"
}
function setCommandToSecretsApplyToAllNamespaces() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_APPLY_TO_ALL_NAMESPACES}"
}
function setCommandToCreateProject() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_CREATE_PROJECT}"
}
function setCommandToCreateDeploymentOnlyProject() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_CREATE_DEPLOYMENT_ONLY_PROJECT}"
}
function setCommandToCreateJenkinsUserPassword() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_CREATE_JENKINS_USER_PASSWORD}"
}

##########
# Process arguments and set defaults
#
function processArguments() {
    # check arguments
    for i in "$@"
    do
        case ${i} in
            --nodialog)
                K8S_MGMT_NO_DIALOG="true"
                shift
            ;;
            ## options
            # directory, where the project configuration is located
            -p=*|--projectdir=*)
                K8S_MGMT_PROJECT_DIRECTORY="${i#*=}"
                shift # past argument=value
            ;;
            # name of the namespace
            -n=*|--namespace=*)
                K8S_MGMT_NAMESPACE="${i#*=}"
                shift # past argument=value
            ;;
            # name of the deployment
            -d=*|--deploymentname=*)
                JENKINS_MASTER_DEPLOYMENT_NAME="${i#*=}"
                shift # past argument=value
            ;;
            -o=*|--output-dry-run-file=*)
                K8S_MGMT_YAML_OUTPUT_FILE="${i#*=}"
                shift # past argument=value
            ;;

            ## arguments
            # install Jenkins
            install)
                setCommandToInstall
                shift # past argument=value
            ;;
            # uninstall Jenkins
            uninstall)
                setCommandToUnInstall
                shift # past argument=value
            ;;
            # upgrade Jenkins installation
            upgrade)
                setCommandToUpgrade
                shift # past argument=value
            ;;
            # encrypt the secrets
            encryptsecrets)
                setCommandToSecretsEncrypt
                shift # past argument=value
            ;;
            # decrypt the secrets
            decryptsecrets)
                setCommandToSecretDecrypt
                shift # past argument=value
            ;;
            # apply secrets to kubernetes
            applysecrets)
                setCommandToSecretsApply
                shift # past argument=value
            ;;
            # apply secrets to kubernetes
            applysecretstoallnamespaces)
                setCommandToSecretsApplyToAllNamespaces
                shift # past argument=value
            ;;
            # create new project
            createproject)
                setCommandToCreateProject
                shift # past argument=value
            ;;
            # create new application project
            createdeploymentonlyproject)
                setCommandToCreateDeploymentOnlyProject
                shift # past argument=value
            ;;
            # create a password
            createJenkinsUserPassword)
                setCommandToCreateJenkinsUserPassword
                shift # past argument=value
            ;;
            *)
                # unknown option
            ;;
        esac
    done
}