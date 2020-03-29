# Kubernetes Jenkins as Code management #

!!! UNDER CONSTRUCTION !!!

This project offers a template for managing Jenkins instances on Kubernetes with a JobDSL and Jenkins Configuration as Code (JcasC).

To simplify the installation and the project settings, it has a small helper tool `k8s-jcasc.sh`, which can be used in wizard mode or via arguments to
* create new projects for Jenkins administration
* manage secrets
    * encrypt/decrypt secrets for secure commit to a VCS (version control system)
    * apply secrets to kubernetes
    * manage secrets globally for easy administration
    * manage secrets per project for more security
* manage the Jenkins instances for a namespace with the project configuration (not ready yet)
    * install
    * uninstall


## How to use ##

The simplest way is to call the `k8s-jcasc.sh` file. Everything else will be asked by the script.

For less selection and more control you can also give some arguments and the command to the script:

```bash
./k8s-jcasc.sh <arguments> <command>
```

The order of the arguments and commands are irrelevant.

### k8s-jcasc.sh arguments ###

It is possible to use multiple arguments.
The following arguments are supported:

| Argument | Description | Example |
| --- | --- | --- |
| `-p=` or `--projectdir=` | Defines the project directory (or project name) of the Jenkins configuration. This directory is a subdirectory of the configured `PROJECTS_BASE_DIRECTORY` | `-p=myproject` or `--projectdir=myproject` |
| `-n=` or `--namespace=` | Defines the target namespace in Kubernetes. It is not used for encrypting or decrypting secrets. | `-n=jenkins-namespace` or `--namespace=jenkins-namespace` |
| `-d=` or `--deploymentname=` | Defines the deployment name, which is relevant only for `install` and `uninstall`. This can also be configured globally for all projects as `JENKINS_MASTER_DEPLOYMENT_NAME` in the config file. | `-d=jenkins-master` or `--deploymentname=jenkins-master` |

### k8s-jcasc.sh commands ###

Only one command can be used. Multiple commands are *NOT* supported.
The following commands are supported:

| Command | Description |
| --- | --- |
| `install` | Install Jenkins to a Kubernetes namespace. |
| `uninstall` | Uninstall the Jenkins instance from a Kubernetes namespace. |
| `encryptsecrets` | Encrypt the secrets (global secrets or project secrets, depending on configuration). |
| `decryptsecrets` | Decrypt the secrets (global secrets or project secrets, depending on configuration). |
| `applysecrets` | Apply the secrets to the Kubernetes namespace (global secrets or project secrets, depending on configuration). |
| `createproject` | Create a new Jenkins project for the configuration and deployment values from the templates. It uses a wizard to ask for relevant data. |


# Helpful links #

- Kubernetes DNS-Based Service Discovery: https://github.com/kubernetes/dns/blob/master/docs/specification.md
- JCasC Examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos