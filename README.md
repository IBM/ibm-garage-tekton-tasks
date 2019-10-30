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

### Create Tasks

Install the tasks.

```bash
kubectl create -f ibm-garage-tekton-tasks/tasks -n dev
```

### Create Pipeline

- Create pipeline for each environment for example the `dev` namespace.

#### nodejs typescipt

```bash
kubectl create -f ibm-garage-tekton-tasks/pipelines/node-typescript-pipeline.yaml -n dev
```

#### java springboot

```bash
kubectl create -f ibm-garage-tekton-tasks/pipelines/java-spring-pipeline.yaml -n dev
```

### Create Git Webhook

- Create a Git Webhook on the `dev` namespace using the tekton dashboard.

Now, your pipeline runs whenever the changes are pushed to the repository.
