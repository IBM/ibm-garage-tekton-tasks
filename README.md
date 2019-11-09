## Tekton Pipelines

Let us build a tekton pipelines for different templates. For each template, perform the following steps.

1. Install the tasks that are required by the pipeline.
2. Create the pipeline.
3. Create git webhook in tekton.

### Get the code

Clone this repo.

```bash
git clone https://github.com/ibm-garage-cloud/ibm-garage-tekton-tasks.git
```

## Service account to run Pipeline

Create a service account like `pipeline`
```
oc create serviceaccount pipeline
oc adm policy add-scc-to-user privileged -z pipeline
oc adm policy add-role-to-user edit -z pipeline
```



### Create Pipeline Tasks

IMPORTANT: If Tekton version is lower than `0.7.0` then use the tasks from the `pre-0.7.0` directory.

- Create pipelines tasks for each environment for example the `dev` namespace:

    ```bash
    kubectl create -f ibm-garage-tekton-tasks/pre-0.7.0/tasks/ -n dev
    ```

- If using Tekton version `0.7.0` or greater use this command instead:

    ```bash
    kubectl create -f ibm-garage-tekton-tasks/tasks/ -n dev
    ```

This step will create the following tasks:
- igc-nodejs-tests
- igc-java-gradle-tests
- igc-build-push.yaml
- igc-build-tag-push.yaml
- igc-build-tag-push-ibm.yaml
- igc-deploy
- igc-health-check
- igc-helm-package
- igc-gitops

### Create Pipelines

- Create pipelines for each environment for example the `dev` namespace.

    ```bash
    kubectl create -f ibm-garage-tekton-tasks/pipelines/ -n dev
    ```

This step will create following Pipelines:

- igc-java-gradle
- igc-nodejs

### Create Git Webhook

- Create a Git Webhook on the `dev` namespace using the tekton dashboard.

Now, your pipeline runs whenever the changes are pushed to the repository.
