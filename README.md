# CloudDevOpsProject

This repository contains the infrastructure, configuration, and deployment setup for a cloud-based application using DevOps principles. The project is structured to demonstrate the use of modern tools such as Docker, Terraform, Ansible, and Jenkins to achieve seamless CI/CD workflows and infrastructure as code.

---

## Project Structure

```plaintext
CloudDevOpsProject/
├── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── modules/
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── variables.tf
│   │   ├── ec2/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── variables.tf
├── ansible/
│   ├── roles/
│   │   ├── common/
│   │   ├── jenkins/
│   │   ├── sonarqube/
│   └── playbook.yml
├── Jenkinsfile
└── docs/
    ├── architecture-overview.md
    ├── setup-instructions.md
    ├── troubleshooting.md
```
---

## Prequesites
### Step 1: Create a Github Repository

- Go to https://github.com/ and create an account.
- Create a new Repository and name it `CloudDevOpsProject`.
- Add README.md file.

### Step 2: Install Git in your machine 

    ```bash
    sudo apt update -y
    sudo apt install git -y
    ```

- Create a directory for the project and name it `Graduation_Project`.
    ```bash
    mkdir Graduation_Project
    ```
- Navigate to the created directory
  ```bash
  cd Graduation_Project
  ```
- Configure Git 
  ```bash
  git config --global user.name <your-username>
  git config --global user.email <your-email>
  ```
- Initialize a Git Repository 
  ```bash
  git init
  ```
- Copy the `ssh` url from the Created Github Repo UI
- Use the following command to connect the local repo to the remote repo on Github
    ```bash
    git remote add origin <Git-Repo-ssh-Url>
    ```
---
## Steps
### Step 1: Establish the Infrastructure using Terraform.

[Read the README for Terraform](./Terraform/README.md)

### Step 2: Configure the Infrastructure using Ansible.

[Read the README for Ansible](./Ansible/README.md)
