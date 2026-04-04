# Jenkins Terraform S3 Deployment

This project demonstrates a CI/CD pipeline using **Jenkins** and **Terraform** to deploy a static website to **AWS S3**.

---

## 🚀 Features

- Pulls source code from GitHub
- Provisions AWS S3 bucket and static website hosting using Terraform
- Uploads website files to S3
- Retrieves Terraform outputs and displays the website URL in Jenkins

---

## 📋 Prerequisites

### Jenkins Plugins

Ensure the following plugins are installed:

- Pipeline: SCM Step  

### Agent Requirements

The Jenkins agent must have:

- Git  
- Terraform (v1.14+)  
- AWS CLI (v2+)  

### AWS Credentials

Create an IAM user with the following permission:

- `AmazonS3FullAccess`

Store credentials in Jenkins as **Secret Text**:

| Credential ID     | Value              |
|------------------|-------------------|
| `aws-access-key` | Access Key ID     |
| `aws-secret-key` | Secret Access Key |

---

## ⚙️ Setup

1. Create a **Pipeline from SCM** in Jenkins  
2. Point it to this repository  
3. Configure AWS credentials in Jenkins  
4. Ensure the Jenkins agent has required tools installed  
5. Run the pipeline  

---

## Pipeline Parameters

### `TFVARS`

Terraform variables used during deployment:

```hcl
aws_region  = "us-east-1"
bucket_name = "my-unique-static-site-bucket-12345"
environment = "dev"
```

---

## 📝 Notes

- All shell scripts use Bash (`#!/bin/bash`) for compatibility  
- Pipeline automatically cleans up:
  - `dev.tfvars`
  - `tfplan`
- AWS credentials are securely masked in Jenkins console output  

---

## 📤 Output

After a successful pipeline run, Jenkins will display:

```
Website URL: http://<your-bucket-website-url>
```
