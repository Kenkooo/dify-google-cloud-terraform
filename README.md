# Terraform for Dify on Google Cloud

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-1.9.5-blue.svg)


![Dify GCP Architecture](images/dify-google-cloud-architecture.png)

<a href="./README_ja.md"><img alt="日本語のREADME" src="https://img.shields.io/badge/日本語-d9d9d9"></a>

> [!NOTE]
> - Dify v1.0.0 (and later) is supported now! Try it and give us feedbacks!!
> - If you fail to install any plugin, try several times and succeed in many cases.

## Overview
This repository allows you to automatically set up Google Cloud resources using Terraform and deploy Dify in a highly available configuration.

## Features
- Serverless hosting
- Auto-scaling
- Data persistence

## Prerequisites
- Google Cloud account
- Terraform installed
- gcloud CLI installed

## Configuration
- Create a workspace configuration file for each environment (supported formats: `*.tfvars.json`, `*.tfvars.yaml`, or `*.tfvars.yml`). For example: `terraform/workspace/workspaces/dev.tfvars.json`.

> [!WARNING]
> **Security Alert: Handling workspace configuration files**
> The `terraform/workspace/workspaces/dev.tfvars.json` file in this repository is a **template only**. Populate it locally with your actual configuration (project ID, secrets, secure password).
>
> **Do NOT commit workspace configuration files containing sensitive data to Git.** This poses a significant security risk.
>
> Add `*.tfvars`, `*.tfvars.json`, `*.tfvars.yaml`, and `*.tfvars.yml` to your `.gitignore` file immediately to prevent accidental commits. For secure secret management, use environment variables (`TF_VAR_...`) or tools like Google Secret Manager.

- Create a GCS bucket to manage Terraform state in advance, and replace "your-tfstate-bucket" in the `terraform/workspace/provider.tf` file with the name of the created bucket.

## Getting Started
1. Clone the repository:
    ```sh
    git clone https://github.com/Kenkooo/dify-google-cloud-terraform.git
    ```

2. Initialize Terraform:
    ```sh
    cd terraform/workspace
    terraform init
    ```

3. Create (or select) a Terraform workspace for the environment you want to deploy. For example, to use a `dev` environment:
    ```sh
    terraform workspace new dev
    # or select an existing workspace
    terraform workspace select dev
    ```

4. Make Artifact Registry repository:
    ```sh
    terraform apply -target=module.registry
    ```

5. Build & push container images:
    ```sh
    cd ../../..
    sh ./docker/cloudbuild.sh <your-project-id> <your-region>
    cd terraform/workspace
    ```
    You can also specify a version of the dify-api and dify-sandbox images.
    ```sh
    sh ./docker/cloudbuild.sh <your-project-id> <your-region> <dify-api-version> <dify-sandbox-version>
    ```
    If no version is specified, the latest version is used by default.

## Container images and Artifact Registry layout

- `docker/api` and `docker/nginx` contain the Dockerfiles that customise the upstream Dify images. The `docker/sandbox` folder was
  added so you can mirror the optional `langgenius/dify-sandbox` image into your own Artifact Registry project before running
  Terraform.
- `terraform apply -target=module.registry` creates three **standard** Artifact Registry repositories (nginx, api, sandbox) where
  Cloud Build pushes the images built by `docker/cloudbuild.sh`.
- The same module also creates **remote repositories** for `dify-web` and `dify-plugin-daemon`. These repositories transparently
  proxy the official images on Docker Hub, so there is no dedicated folder under `docker/`. When Cloud Run is deployed, it pulls
  the upstream images via Artifact Registry without you having to maintain a local Dockerfile for them.

6. Terraform plan:
    ```sh
    terraform plan
    ```

7. Terraform apply:
    ```sh
    terraform apply
    ```


## Cleanup
```sh
terraform destroy
```

Note: Cloud Storage, Cloud SQL, VPC, and VPC Peering cannot be deleted with the `terraform destroy` command. These are critical resources for data persistence. Access the console and carefully delete them. After that, use the `terraform destroy` command to ensure all resources have been deleted.

## References
- [Dify](https://dify.ai/)
- [GitHub](https://github.com/langgenius/dify)

## License
This software is licensed under the MIT License. See the LICENSE file for more details.
