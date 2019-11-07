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

IMPORTANT: If Tekton version is lower than `0.7.0` then use the pipeline and tasks from the `pre-0.7.0` directory.

### Create Tasks

Install the tasks.

```bash
kubectl create -f ibm-garage-tekton-tasks/pre-0.7.0/tasks/ -n dev
```

or for Tekton version `0.7.0`+

```bash
kubectl create -f ibm-garage-tekton-tasks/tasks/ -n dev
```

### Create Pipeline

- Create pipeline for each environment for example the `dev` namespace.

```bash
kubectl create -f ibm-garage-tekton-tasks/pre-0.7.0/pipelines/ -n dev
```

or for Tekton version `0.7.0`+

```bash
kubectl create -f ibm-garage-tekton-tasks/pipelines/ -n dev
```

### Create Git Webhook

- Create a Git Webhook on the `dev` namespace using the tekton dashboard.

Now, your pipeline runs whenever the changes are pushed to the repository.
