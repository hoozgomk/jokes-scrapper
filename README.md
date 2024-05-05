# jokes-scrapper

This repository contains:
- simple python app which scrapes the latest 100 jokes from bash.org.pl and returns them in JSON format under /jokes endpoint
- Dockerfile for building docker image
- Terraform manifest to create a VM instance and additional configuration to deploy the docker container
- Github Actions workflow for building docker image, pushing it to Artifact Registry and deploying it to VM intance.

This setup is parametrized to be deployed on GCP project. 

To set up the environment, following steps have to be executed:

1. Obtain Service Account JSON key file which has necessary permissions to create infrastructure within your project. The role roles/compute.admin role is necessary for this setup.
From terraform folder, perform accordingly:
    ```terraform init```
    ```terraform plan -var="credentials_file=/path/to/your/credentials.json" ```
    ```terraform apply -var="credentials_file=/path/to/your/credentials.json"```

3. Run "deploy" GitHub actions Workflow, which:
   - authenticates to Google and Docker
   - retrieves the external IP of the VM
   - builds and pushes the Docker image to Artifact Registry
   - executes docker pull && docker run commands on VM instance over SSH

The application runs on port 8000 and exposes /jokes GET endpoint. After the successful deployment, application will be accessible under VM external IP address.
Example URL: 34.67.103.201:8000/jokes

## How to test the application locally:

1. create python venv
2. install requirements.txt
3. execute command: 
   ```python app/main.py```

## How to build and run docker image locally:

1. build docker image:
   ```docker build -t jokes-scrapper:<your-tag> .```
2. run docker container:
   ```docker run -p 8000:8000 jokes-scrapper:<your-tag>```

