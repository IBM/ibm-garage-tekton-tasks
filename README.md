# IBM Cloud Garage Tekton Pipelines

This repository provides Tekton pipelines and tasks [IBM Cloud Native Toolkit](https://cloudnativetoolkit.dev/) Starter Kits.

## Install the tasks and pipelines

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

## Get the code

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

## Managing container images

Each of the tasks that make up the pipeline uses one or more container within which
the logic will run. Previously, many of these images were hosted in Docker Hub. However,
the recent rate limits imposed by Docker Hub on pulling images poses a problem for the pipelines
and we have experienced hitting that limit when running a handful of pipelines
at the same time in the same cluster.

In order to address this we have started mirroring those images in quay.io under the `ibmgaragecloud` organization. For now
we are using a poor-mans approach to mirroring via a GitHub Action workflow. There are three parts to this process:

### 1. `mapping.txt`

Provides the mapping from the source image to the destination in quay.io. The file follows the 
structure of the Red Hat mapping file and can be used as input to `oc image mirror` if desired. Each line defines a different
repository that should be mirrored. Optionally, a specific source tag can be identified using the `:tag` syntax. If
no tag is provided then the most recent 5 tags will be mirrored.

If a new image or a new tag for an existing image is introduced in the tasks then
this file should be updated to include that image and/or tag.

### 2. `bin/mirror.sh`

Reads the `mapping.txt` file and mirrors the image into the destination location using
`skopeo`. It takes the username and password of the destination registry as input to allow
the image to be pushed. (It is assumed that the image can be pulled anonymously and does
not need credentials.)

### 3. `.github/workflows/mirror-images.yaml`

The GitHub Action workflow that triggers the mirroring process. The workflow will be
triggered on a schedule at 1am every morning and each time a change is
pushed to the `main` branch.

It gets the values for the registry user and registry password from secrets in the Git repo.
