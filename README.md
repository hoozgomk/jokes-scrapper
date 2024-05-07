# jokes-scrapper

This repository contains:
- simple python app which scrapes the latest 100 jokes from bash.org.pl and returns them in JSON format under /jokes endpoint
- Dockerfile for building docker image
- Terraform manifest to create a VM instance and additional configuration to deploy the docker container
- Github Actions workflow for building docker image, pushing it to Artifact Registry and deploying it to the VM instance.

This setup is parametrized to be deployed on GCP project. 

## To set up the environment, following steps must be executed:

1. Obtain GCP Service Account JSON key file which has necessary permissions to create infrastructure within your project. The role roles/compute.admin role is a minimal role for this setup.
Save this key as credentials.json locally. This key will be used to provision VM instance with Terraform. 
2. Generate SSH key pair. This SSH keys will be used to allow GitHub Actions to connect to the VM instance.
   1. Save private key to the GitHub repository secret called SSH_PRIVATE_KEY
   2. When deploying Terraform code, provide path to public key as listed below.
3. From terraform folder, perform accordingly:

    ```terraform init```

    ```terraform plan -var="credentials_file=/path/to/your/credentials.json" -var="public_key_file=/path/to/your/ssh_pub_key_file"```

    ```terraform apply -var="credentials_file=/path/to/your/credentials.json" -var="public_key_file=/path/to/your/ssh_pub_key_file"```

4. Obtain Service Account JSON key file which has necessary permissions to read the repositories from Artifact Registry. The role roles/artifactregistry.reader is a minimal role which allows it.
   1. Save this SA to the GitHub Repository secret called GCP_AR_SA_KEY
5. Run "deploy" GitHub actions Workflow, which:
   - authenticates to Google and Docker
   - retrieves the external IP of the VM
   - builds and pushes the Docker image to Artifact Registry
   - executes docker pull && docker run commands on VM instance over SSH

The application runs on port 8000 and exposes /jokes GET endpoint. After the successful deployment, application will be accessible under VM external IP address.
Example URL: 34.67.103.201:8000/jokes

### How to test the application locally:

1. create python venv
2. install requirements.txt
3. execute command: 
   ```python app/main.py```

### How to build and run docker image locally:

1. build docker image:
   ```docker build -t jokes-scrapper:<your-tag> .```
2. run docker container:
   ```docker run -p 8000:8000 jokes-scrapper:<your-tag>```

