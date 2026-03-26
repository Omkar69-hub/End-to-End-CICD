# 🚀 End-to-End CI/CD with Terraform & AWS

A complete **CI/CD pipeline** that automatically provisions AWS infrastructure using **Terraform** and deploys a **Node.js** application via **Docker** and **Amazon ECR** — all triggered by a simple `git push`.

---

## 📐 Architecture Overview

```
GitHub Push (main)
        │
        ▼
┌─────────────────────────┐
│   GitHub Actions CI/CD  │
│                         │
│  ┌─────────────────┐    │
│  │  deploy-infra   │    │   ┌──────────────────────┐
│  │  (Terraform)    │────┼──▶│  AWS EC2 (t3.micro)  │
│  └─────────────────┘    │   │  Ubuntu / Amazon Linux│
│           │             │   └──────────────────────┘
│           │ IP output   │              ▲
│           ▼             │              │ docker run
│  ┌─────────────────┐    │   ┌──────────────────────┐
│  │  deploy-appl    │────┼──▶│   Amazon ECR         │
│  │  (Docker+ECR)   │    │   │  (Container Registry)│
│  └─────────────────┘    │   └──────────────────────┘
└─────────────────────────┘
```

---

## 🗂️ Project Structure

```
End-to-End CICD/
├── .github/
│   └── workflows/
│       └── deploy.yaml        # GitHub Actions CI/CD pipeline
├── nodeapp/
│   ├── app.js                 # Express.js application
│   ├── Dockerfile             # Docker image definition
│   ├── .dockerignore          # Files excluded from Docker build
│   ├── package.json           # Node.js dependencies
│   └── package-lock.json
├── terraform/
│   ├── main.tf                # EC2, Security Group, Key Pair, IAM resources
│   ├── variables.tf           # Input variable declarations
│   └── terraform.tfvars       # Variable values (SSH key, key name)
└── .gitignore                 # Ignores .pem keys, tfstate files, etc.
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Application** | Node.js 14 + Express.js |
| **Containerisation** | Docker |
| **Container Registry** | Amazon ECR |
| **Infrastructure as Code** | Terraform (AWS Provider v6.21.0) |
| **Cloud** | AWS EC2 (t3.micro), AWS S3 (remote state) |
| **CI/CD** | GitHub Actions |
| **Region** | `ap-south-1` (Mumbai) |

---

## ⚙️ CI/CD Pipeline — `deploy.yaml`

The pipeline is split into **two sequential jobs**:

### Job 1: `deploy-infra` — Provision AWS Infrastructure

| Step | Description |
|---|---|
| Checkout code | Pulls repo into the runner |
| Setup Terraform | Installs Terraform via `hashicorp/setup-terraform@v2` |
| Verify secrets | Safely confirms all secrets are injected |
| Write private key | Writes `$AWS_SSH_KEY_PRIVATE` to `./terraform/keys/deployer.pem` |
| `terraform init` | Initialises backend with S3 remote state |
| `terraform plan` | Plans infra changes with region, key name, and public key |
| `terraform apply` | Creates EC2 instance, security group, key pair, IAM profile |
| Capture EC2 IP | Reads `instance_public_ip` output and stores it for the next job |
| Wait for EC2 | Sleeps 90 seconds to let the EC2 instance boot |

### Job 2: `deploy-appl` — Build & Deploy Application

| Step | Description |
|---|---|
| Checkout code | Pulls repo |
| Set IP variable | Reads EC2 IP from Job 1's output |
| Login to ECR | Authenticates with `aws-actions/amazon-ecr-login@v1` |
| Build & push image | Builds Docker image tagged with `$GITHUB_SHA`, pushes to ECR |
| SSH deploy to EC2 | SSHes into EC2, installs Docker & AWS CLI, pulls image from ECR, starts container on port 80 |

---

## 🏗️ Terraform Infrastructure (`terraform/main.tf`)

### Resources Provisioned

| Resource | Details |
|---|---|
| `aws_instance` | `t3.micro`, AMI `ami-0d176f79571d18a8f`, public IP enabled |
| `aws_security_group` | Allows **inbound** SSH (22) and HTTP (80); full **outbound** |
| `aws_key_pair` | `deployer-key` created from the public key variable |
| `aws_iam_instance_profile` | `ec2-profile` linked to `EC2-Authentication` IAM role |

### Remote State Backend

Terraform state is stored remotely in **S3**:
- **Bucket:** `ec2-terraform-and-aws-project-bucket`
- **Key:** `aws/ec2-deploy/terraform.tfstate`
- **Region:** `ap-south-1`

---

## 📦 Node.js Application (`nodeapp/`)

A minimal **Express.js** HTTP server:

```js
// app.js
const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
  res.send('Service is up and running');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
```

The Dockerfile runs the app on **port 8080** inside the container, mapped to **port 80** on the EC2 host.

---

## 🔐 GitHub Secrets Required

Set the following secrets in your GitHub repository  
(**Settings → Secrets and variables → Actions**):

| Secret Name | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_TF_STATE_BUCKET_NAME` | S3 bucket name for Terraform remote state |
| `AWS_SSH_KEY_PRIVATE` | Private SSH key (PEM format) for EC2 access |
| `AWS_SSH_KEY_PUBLIC` | Corresponding public SSH key |
| `SERVER_PUBLIC_IP` | *(Optional)* Pre-known EC2 IP (auto-set by pipeline) |

---

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed locally
- [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure`)
- [Docker](https://docs.docker.com/get-docker/) installed
- An **AWS ECR repository** named `nodeapp` created in `ap-south-1`
- An **IAM Role** named `EC2-Authentication` with ECR pull permissions attached

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/End-to-End-CICD.git
cd "End-to-End CICD"
```

### 2. Configure AWS ECR

```bash
# Create the ECR repository (one-time setup)
aws ecr create-repository --repository-name nodeapp --region ap-south-1
```

### 3. Configure GitHub Secrets

Add all secrets listed in the [🔐 GitHub Secrets Required](#-github-secrets-required) section to your repository.

### 4. Push to `main` to Trigger the Pipeline

```bash
git add .
git commit -m "trigger deployment"
git push origin main
```

The GitHub Actions pipeline will automatically:
1. **Provision** an EC2 instance via Terraform
2. **Build** the Docker image and push it to ECR
3. **Deploy** the container on the new EC2 instance

### 5. Access the Application

Once the pipeline completes, open a browser and navigate to:

```
http://<EC2-PUBLIC-IP>
```

You should see: `Service is up and running`

---

## 🔄 How the Pipeline Flows

```
git push origin main
        │
        ▼
  GitHub Actions triggered
        │
        ├──[ Job 1: deploy-infra ]──────────────────────────────────┐
        │     1. terraform init  (S3 backend)                       │
        │     2. terraform plan  (EC2 + SG + Key + IAM)             │
        │     3. terraform apply (provisions infrastructure)         │
        │     4. capture EC2 public IP → outputs.instance_public_ip │
        │     5. wait 90s for instance boot                         │
        │                                                            ▼
        └──[ Job 2: deploy-appl (needs: deploy-infra) ]────────────▶│
              1. docker build -t <ecr-repo>/<image>:<sha> .          │
              2. docker push <ecr-repo>/<image>:<sha>                │
              3. SSH into EC2                                         │
              4. apt install docker + awscli                         │
              5. aws ecr get-login-password | docker login           │
              6. docker pull <image>                                  │
              7. docker run -d -p 80:3000 <image>                    │
                                                                     ▼
                                                       ✅ App live on EC2:80
```

---

## 📁 Key Files Reference

| File | Purpose |
|---|---|
| [`.github/workflows/deploy.yaml`](.github/workflows/deploy.yaml) | Full CI/CD pipeline definition |
| [`terraform/main.tf`](terraform/main.tf) | AWS infrastructure (EC2, SG, IAM, Key Pair) |
| [`terraform/variables.tf`](terraform/variables.tf) | Terraform input variable declarations |
| [`nodeapp/app.js`](nodeapp/app.js) | Express.js application entry point |
| [`nodeapp/Dockerfile`](nodeapp/Dockerfile) | Docker image build instructions |
| [`.gitignore`](.gitignore) | Excludes sensitive files (`.pem`, `.tfstate`) |

---

## ⚠️ Security Notes

- **Never commit `.pem` private keys** — they are excluded via `.gitignore`.
- **Terraform state** is stored remotely in S3 (not in the repo).
- **Secrets** are injected exclusively via GitHub Secrets — never hardcoded.
- The EC2 security group currently allows SSH (port 22) from `0.0.0.0/0`. For production, restrict this to your own IP.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
