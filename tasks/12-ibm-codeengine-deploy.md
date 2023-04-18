# IBM-CodeEngine-Deployment-Tasks

The purpose of the tekton task is to deploy the application, that is built as an Image, to the IBM Code Engine platform. IBM Code Engine is a fully managed, serverless platform that runs the containerized workloads.

The pre-requiste for the tasks are as below:
- to set the Project on the IBM Code Engine
- Configure the Image Registry Access for Code Engine Access during deployment, as part of the IBM Code Engine


To execute the task, ensure the below parameters are passed with right set of values to the Tekton Task:


- ce_deploy -- This parameter is set to true or false. If the flag is set to true, then Code Engine Deployment is triggered and the parameters that follow has be provided appropriately. If the flag is set to false, then Code Engine Deployment is not enabled and the following parameter or not needed. The Default value of this parameter is 'false'
- ce_project_name - This parameter captures the Project Name created as part of the IBM Code Engine. This is a Mandatory Parameter.
- ce_app_name  - This parameter captures the Application Name which is to be deployed in the IBM Code Engine. This is a Mandatory Parameter.
- ce_image_access - This parameter captures the Image Registry Access Name created as part of the IBM Code Engine. This is used by the Code Engine to access the Image Registry to pull the Application Image. This is a Mandatory Paramter.
- ce_region - This parameter captures the IBM Cloud Region where the IBM Code Engine is provisioned.  This is a Mandatory Parameter.
- ce_resource_group - This parameter captures the Resource Group under which IBM Cloud Engine is provisoned. This is a Mandatory Parameter.
- ce_cpu - This parameter captures the CPU requirement for the Application. If value is not passed, by default it uses 0.5 CPU resources for the application
- ce_memory - This parameter captures the memory requirement for the Application. If value is not passed, by default it uses 1 GB memory resources for the application. Please refer to the IBM Code Engine Documentation for Memory Mapping to appropriate CPU requirement.
- ce_min_scale - This parameter captures the number of minimum infrastructure needed. By default 0 is set a min scale, i.e until the application is accessed or idle the no infra will be provisioned. The Infra will be provisioned only when the application is access when set to 0.
- ce_min_scale - This parameter capture the max. infra can be provisioned for the application based on the resource utilization. By default this is set to 10.

- APIKEY - This parameter is used from the ibmcloud-apikey Secrets of the Openshift Namespace Environment. Unlike the previous parameters, this is not passed from the previous stage, but used from the Key of ibmcloud-apikey Secrets.






