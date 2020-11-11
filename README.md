## IBM Cloud Garage Tekton Pipelines

This repository provides Tekton pipelines and tasks [IBM Cloud Native Toolkit](https://cloudnativetoolkit.dev/) Starter Kits.

### Install the tasks and pipelines

The best way to install the tasks and template pipelines is through the versioned releases. The following
steps will get the tasks installed in your cluster. **Note:** These instructions assume you have already
logged into the cluster.

1. Look through the releases and select the one that should be installed - https://github.com/IBM/ibm-garage-tekton-tasks/releases
2. From the command-line, run the following (substituting the `RELEASE` and `NAMESPACE` values as appropriate):
    ```shell script
    RELEASE=$(curl -s https://api.github.com/repos/IBM/ibm-garage-tekton-tasks/releases/latest | jq -r '.tag_name')
    export NAMESPACE="tools"
    kubectl apply -n ${NAMESPACE} -f "https://github.com/IBM/ibm-garage-tekton-tasks/releases/download/${RELEASE}/release.yaml"
    ```

### Get the code

- Clone this repository
    ```bash
    git clone git@github.com:IBM/ibm-garage-tekton-tasks.git
    cd ibm-garage-tekton-tasks
    ```

## Service account to run Pipeline

If you install Tekton using the OpenShift Pipeline Operator on OCP4, a service account `pipeline` is already created and you can skip the following commands.

- Create a service account like `pipeline`
    ```
    oc create serviceaccount pipeline
    oc adm policy add-scc-to-user privileged -z pipeline
    oc adm policy add-role-to-user edit -z pipeline
    ```

### Create Pipeline Tasks

- Create pipelines tasks for each environment for example the `dev` namespace:
    ```bash
    kubectl create -f tasks/ -n dev
    ```

This step will create the following tasks:
- ibm-nodejs-tests
- ibm-java-gradle-tests
- ibm-build-push.yaml
- ibm-build-tag-push.yaml
- ibm-build-tag-push-ibm.yaml
- ibm-deploy
- ibm-health-check
- ibm-helm-package
- ibm-gitops

### Create Pipelines

- Create pipelines for each environment for example the `dev` namespace.
    ```bash
    kubectl create -f pipelines/ -n dev
    ```

This step will create following Pipelines:

- ibm-appmod-liberty
- ibm-golang-edge
- ibm-golang
- ibm-java-gradle
- ibm-java-maven
- ibm-nodejs

### Manually run a Pipeline

- Run a pipeline for one of the application templates using the Tekton CLI `tkn` and the helper script
    ```bash
    Usage: test/scripts/run.sh [go-gin | nodejs-typescript | nodejs-react | nodejs-angular | nodejs-graphql | java-spring]
    ```
    For example to run the pipeline for the application template `nodejs-typescript`
    ```bash
    test/scripts/run.sh nodejs-typescript
    ```
    The script will output the name of the pipelinerun, and a command to follow the logs
    ```
    Pipelinerun started: ibm-nodejs-run-fqgr7
    ```

### Create Git Webhook

- Create a Git Webhook on the `dev` namespace using the tekton dashboard.

Now, your pipeline runs whenever the changes are pushed to the repository.
