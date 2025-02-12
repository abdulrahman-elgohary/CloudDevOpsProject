  # CloudDevOpsProject

This repository contains the infrastructure, configuration, and deployment setup for a cloud-based application using DevOps principles. The project is structured to demonstrate the use of modern tools such as `Docker`, `Terraform`, `Ansible`, `Jenkins` and `Argocd` to achieve seamless CI/CD workflows and infrastructure as code.

---
## Table of Contents

- **[CI/CD Pipeline Overview](#ci-cd-pipeline-overview)**
- **[Project Structure](#project-structure)**
- **[Prequisites](#prequesites)**
- **[Steps](#steps)**
  - [**Step 1:** Establish the Infrastructure using Terraform](#step-1-establish-the-infrastructure-using-terraform)
  - [**Step 2:** Configure the Infrastructure using Ansible](#step-2-configure-the-infrastructure-using-ansible)
  - [**Step 3:** Jenkins Configuration](#step-3-jenkins-configuartion)
  - [**Step 4:** Setup Jenkins Slave](#step-4-setup-jenkins-slave)
  - [**Step 5:** Create the Shared Library](#step-5-create-the-shared-library)
  - [**Step 6:** SonarQube Configuration](#step-6-sonarqube-configuration)
  - [**Step 7:** Shared Library functions](#step-7-shared-library-functions)
  - [**Step 8:** Create a Pipeline project with Github Webhook](#step-8-create-a-pipeline-project-with-github-webhook)
  - [**Step 9:** Minikube Cluster](#step-9-minikube-cluster)
  - [**Step 10:** Create the Cluster resources](#step-10-create-the-cluster-resources)
  - [**Step 11:** Argocd Installation](#step-11-argocd-installation)
  - [**Step 12:** Argocd Configuration](#step-12-argocd-configuration)


---
## CI CD Pipeline Overview

**This project utilizes a `Jenkins Pipeline` defined in a Jenkinsfile that orchestrates the following stages**:

1. **Checkout Code**: Clones the repository from GitHub.

2. **Build Application**: Compiles the code and packages it into a JAR file.

3. **Run Unit Tests**: Ensures the application's quality.

4. **Run SonarQube Analysis**: Checks code quality and coverage.

5. **Build Docker Image**: Creates a Docker image from a dockerfile for the application.

6. **Push Image to Docker Hub**: Pushes the built Docker image to Docker Hub.

7. **Update the deployment**: Changes the deployment file with the new image.

8. **Push the deployment to Github**: Pushes the new deployment file to Github 

9. **Deploy to Kubernetes**: Deploys the new version of the application using Kubernetes with the help of `Argocd`.

---

## Project Structure

```plaintext
CloudDevOpsProject/
├── Terraform/
│   ├── backend.tf
│   ├── main.tf
│   ├── modules
│   │   ├── ec2
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── iam_role
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── security_group
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── subnet
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── vpc
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── provider.tf
│   ├── README.md
│   ├── terraform.tfvars
│   └── variables.tff
├── Ansible/
│   ├── ansible.cfg
│   ├── aws_ec2.yml
│   ├── playbook.yml
│   ├── README.md
│   └── roles
│       ├── Docker
│       │   ├── handlers
│       │   │   └── main.yml
│       │   └── tasks
│       │       └── main.yml
│       ├── Jenkins
│       │   ├── handlers
│       │   │   └── main.yml
│       │   └── tasks
│       │       └── main.yml
│       ├── Preinstall
│       │   └── tasks
│       │       └── main.yml
│       └── SonarQube
│           ├── handlers
│           │   └── main.yml
│           ├── tasks
│           │   └── main.yml
│           └── vars
│               └── main.yml
└── FinalProjectCode/
│   ├── build/
│   ├── gradle/
│   ├── src/
│   ├── build.gradle
│   ├── gradlew.bat
│   ├── settings.gradle
│   ├── Dockerfile
│   ├── deployment.yml
│   ├── service.yml
├── Jenkinsfile
├── README.md
├── application.yml

```
---
## Prequesites
### Step 1: Create a Github Repository

- Go to https://github.com/ and create an account.
- Create a new Repository and name it `CloudDevOpsProject`.
- Add README.md file.
---
### Step 2: Install Git in your machine 

```bash
sudo apt update -y
sudo apt install git -y
```

- Create a directory for the project and name it `Graduation_Project`
```bash
mkdir Graduation_Project
```
- Navigate to the created directory.
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
---
### Step 2: Configure the Infrastructure using Ansible.

[Read the README for Ansible](./Ansible/README.md)
---
### Step 3: Jenkins Configuartion
3.1. **Access Jenkins Web Interface**

- Open a browser and navigate to http://(server-ip):8080.

3.2. **Retrieve Admin Password**

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
3.3. **Complete the Setup Wizard**

- Use the retrieved password to log in.
- Install recommended plugins and set up your admin account.
  
![image](https://github.com/user-attachments/assets/c7156fb9-1d79-452d-b939-549d5af23c7e)
---
### Step 4: Setup Jenkins Slave

- **Launch another Server ssh to it and Install Java.**
  
  ```bash
  sudo apt install openjdk-17-jdk
  ```

- **Install Kubectl on the slave**
  ```bash
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  kubectl version --client
  ```
- **Install Docker**
  
   ```bash
   sudo apt install docker.io -y
   ```
- You will need to change the permissions of `/var/run/docker.sock` on the Jenkins-Agent.

  ```bash
  sudo chmod 662 /var/run/docker.sock
  ```

- **Create Required Ceredentials**
  
- *Create Credentials for the Jenkins to be able to access the dockerhub repo*
- `Manage Jenkins` >> `Credentials` >> `Add Credentials`
- Choose username and password credentials and name it `Docker-Hub`.
  
  ![image](https://github.com/user-attachments/assets/4848a79d-1a99-4775-a5de-2fc4a0bcf515)

- **Generate ssh key to make the slave able to push changes to Github**

  ```bash
  ssh-keygen -t rsa -b 4096
  ```
- **Copy public key content of `~/.ssh/id_rsa.pub`**
- Navigate to `Github Account` > `Settings` > `SSH and GPG Keys` > Paste the Content here and Add the SSH Key
- This will make the Jenkins Slave able to fetch and push from and to Github account

  ![image](https://github.com/user-attachments/assets/1e1bc4b1-5ed5-485d-9a6e-de5d4aae5e83)

- **Copy the private key content of the Ec2  `Slave.pem`**
- Navigate to `Manage Jenkins` > `Credentials` > `New Credential`
- Choose the type `SSH username and private key`
- Paste the content of the private key.
  
- Navigate to `Manage Jenkins` > `Manage Nodes and Clouds` > `New Node`.
- Name the node (e.g., k8s-slave) and choose Permanent Agent.
- In `Host Key Verification Strategy` Choose `Non verifying Verification Strategy`
- In `Remote root Directory` insert the full path of the Directory that will hold all the storage of the slave 
  ![image](https://github.com/user-attachments/assets/e797a31c-66ec-4933-a892-3fa01dd2246a)

---
- **Configure the Node Setting**

- SSH to the Jenkins Agent and Create a directory 
  ```bash
  mkdir /home/ubuntu/jenkins
  ```
- Set the Remote Root Directory (e.g., /home/ubuntu/jenkins/).
- Insert `my-slave` in the label section (This label will be used later in the Jenkinsfile)
- Provide the Launch Method (e.g., SSH).
- Choose the earlier created credentials for the ec2. 
- Create the node

  ![image](https://github.com/user-attachments/assets/1a999ebb-ed27-4e2b-8264-704dadba9824)
---
## Step 5: Create the Shared Library

- In Jenkins, configure the shared library:

- Navigate to `Manage Jenkins` > `Configure System` > `Global Trusted Pipeline Libraries`.
- Add a library name (e.g., shared-lib). (Pay attention to the name it should match the name of the repo)
- Point it to the Git repository containing the shared library.
- Under `Version` insert the branch name that hold your library
- Structure the shared library repository:
  
  ```bash
  shared-lib/
  └── vars/
      ├── gitCheckout.groovy
      ├── unitTest.groovy
      ├── buildJar.groovy
      ├── sonarQubeTest.groovy
      ├── buildandPushImage.groovy
      ├── pushToGithub.groovy
  ```
---
## Step 6: SonarQube Configuration

- **Install Sonnar Qube Scanner Plugin**

- Navigate to `Manage Jenkins` > `Plugins` > Search for `SonarQube Scanner for Jenkins` then install it.
- Navigate to `Manage Jenkins` > `Tools` > `SonarQube Scanner installations` > Give it a name `SonarQube`.

- **Configure SonarQube Token**
- Navigate to `SonarQube` UI > `Administration` > `Security` > `User` > `Update Token`.
  
  ![image](https://github.com/user-attachments/assets/2220208b-41ed-4914-8a7c-4c1b8cfde3fd)

- Navigate to `Manage Jenkins` > `System` >`SonarQube servers` add your environmental variables.
- Create a new Credential for SonarQube using the genreated Token

  ![image](https://github.com/user-attachments/assets/a7917ea1-e2ec-4d2d-9121-9773d5a9fc5f)
---  
### Step 7: Shared Library functions
- Define the scripts in the `vars` directory. Example for `gitCheckout.groovy`:

  ```groovy
  def call(String repoUrl, String branch) {
      checkout scm: [$class: 'GitSCM', branches: [[name: branch]], userRemoteConfigs: [[url: repoUrl]]]
  }
  ```
- Define the scripts in the `vars` directory. Example for `unitTest.groovy`:

  ```groovy
  def call() {
      sh 'chmod +x ./gradlew'
      sh './gradlew test'
  }
  ```
- Define the scripts in the `vars` directory. Example for `buildJar.groovy`:

  ```groovy
  def call() {
      sh './gradlew build --stacktrace'
  }
  ```
- Add the following entry under the section of `plugin` in `build.gradle`.

  ```bash
  id "org.sonarqube" version "4.0.0.2929"
  ```
- At the end of the file add the `sonarqube properties` section.
  
  ```bash
  sonarqube {
      properties {
          property 'sonar.host.url', 'http://54.88.49.239:9000'  // Update this to your SonarQube server URL
          property 'sonar.projectKey', 'clouddevopsproject'     // Update this to your project key
          property 'sonar.projectName', 'clouddevopsproject'   // Update this to your project name
      }
  }
  ```
- Start creating the `sonarQubeTest.groovy` file
 
  ```groovy
  def call(Map envVars) {
      // SonarQube Test
      echo 'Running SonarQube analysis...'
      withSonarQubeEnv(envVars.sonarQubeServer) {
          dir('FinalProjectCode') {
          //Change the sonar to sonarqube if it doesn't work
              sh '''
              ./gradlew sonar 
              '''
          }
      }
  }
  ```
- Start creating the `buildandPushImage.groovy` file
 
  ```groovy
  def call(Map envVars) {
      echo 'Building the Image from dockerfile...'
      dir('FinalProjectCode') {
      sh "docker build -t ${envVars.docker_hub_username}/${envVars.imageName}:${envVars.buildNumber} ."
      }


      echo 'Pushing Docker image to registry...'
      withCredentials([usernamePassword(credentialsId: envVars.registryCredentials, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
      dir('FinalProjectCode') {   
          sh """
          echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
          docker push ${envVars.docker_hub_username}/${envVars.imageName}:${envVars.buildNumber}
          docker rmi ${envVars.docker_hub_username}/${envVars.imageName}:${envVars.buildNumber}
          """
      }
      }
  }
  ```
- It's best practice to delete the image from the agent after pushing it to docker-hub.

- Start creating the `pushToGithub.groovy` file
  
  ```groovy
  def call(Map envVars) {
      sh """
      git config user.name "${envVars.githubUsername}"
      git config user.email "${envVars.githubEmail}"
      git remote set-url origin ${envVars.gitRepo}
      git checkout ${envVars.branch}
      git pull origin ${envVars.branch}
      git add .
      git commit -m "Automated commit by Jenkins" || echo "No changes to commit"
      git push origin ${envVars.branch}
      """
  }
  ```
---
### Step 8. Create a Pipeline project with Github `Webhook` 

- Add the link of the Repo : https://github.com/abdulrahman-elgohary/CloudDevOpsProject.git in the Pipeline Section
  
- Change the branch to main
  
- Add the git repo credentials that you created earlier
  
- Insert the path of Jenkinsfile in the Repo to the `Scriptpath` Section
  
- The content of [Jenkinsfile](./Jenkinsfile)
  
- Check the box of `GitHub hook trigger for GITScm polling`
  
- Navigate to your Github Repository `Settings` > From Left Bar choose `Webhooks` > Add new Webhook > In `Payload URL` Insert `http:(Jenkins-Server-IP:Port)/github-webhook/` > In `Content Type` Choose `application/json` > Save
---
### Step 9. Configure Jenkins For Prometheus
- Navigate to `Manage Jenkins` > `Security` > Under `Authirization` Choose `Role-Based Strategy`.
  
- Navigate to `Manage Jenkins` > `Users` > `Create User` > Name the User `prometheus-user` give it a password ( will be used in the prometheus job configuration).
  
- Navigate to `Manage Jenkins` > `Manage and assign roles` > Add a Role and name it `prometheus` and give it `Overall Read & view Metrics`.
  
- Choose `Assign Roles` from the left bar > `Add User` and Choose the Created Promethues-user > Assign the Created Role Prometheus to the Created User.
  
- Save and Exit. 
---
### Step 10. Configure Prometheus
- Add to `/etc/prometheus/prometheus.yml` the following entry:
  
 ```bash
- job_name: 'jenkins'
              metrics_path: '/prometheus'
              basic_auth:
                username: 'prometheus-user'
                password: '123'
              static_configs:
                - targets: ["Jenkins-server-ip:8080"]
```
 
- This added to Prometheus Configuration using Ansible with other Jobs
  
- Give attention to the `metrics_path` it differes from application to another
  

- Navigate to Prometheus UI `Status` > `Targets` .. You can access the metrics here.

![image](https://github.com/user-attachments/assets/51045993-e6f3-474f-8cb1-1bbf2ae74c82)
---
### Step 11. Configure Grafana
- Navigate to Grafana UI > Enter the default username and password (admin/admin) > Create a new password
  
- At the Left Bar choose `Home` > `Connections` > Search for `Prometheus` in the search bar > `Add new data source` > Under `Connection` > Add the `Prometheus Server IP:9090`
  
- At the Left Bar choose `Home` > `Dashboards` > Choose `New` > `Import` > Use dashboard ID `9964` for Jenkins > Choose `Prometheus` > `Import`

![image](https://github.com/user-attachments/assets/2ad185ab-ce93-4029-9f0a-3cb837f787d2)

```bash
- job_name: 'jenkins'
              metrics_path: '/prometheus'
              basic_auth:
                username: 'prometheus-user'
                password: '123'
              static_configs:
                - targets: ["Jenkins-server-ip:8080"]
```
- Navigate to Prometheus UI `Status` > `Targets` .. You can access the metrics here.

![image](https://github.com/user-attachments/assets/51045993-e6f3-474f-8cb1-1bbf2ae74c82)
### Step 9. Minikube Cluster
- Navigate to your `aws account` > `Ec2` > `Launch Ec2` > Choose `t2.large` size.
- SSH to the Ec2 and install Minikube like the following steps

  ![image](https://github.com/user-attachments/assets/9dfd1d45-2edc-42b4-8e4d-4b29b95d240f)

9.1 **Upate the system**
  
  ```bash
  sudo apt update
  ```
9.2 **Install Docker**

```bash
sudo apt install -y docker.io
```
9.3 **Add the user system to the docker group**

```bash
sudo usermod -aG docker $USER
```
9.4 **Download and Install Minikube**

  ```bash
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  ```
- Move the binary for global access

  ```bash
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  ```
- Start Minikube

  ```bash
  minikube start --driver=docker
  ```
9.5 **Install Kubectl** 

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```
9.6 **Install Kubectl Compeletion**

```bash
sudo apt-get install -y bash-completion
source <(kubectl completion bash)
source ~/.bashrc
```
---
### Step 10: Create the Cluster resources
- Create a file called `deployment.yml` and insert the following entries: **[deployment.yml content](./FinalProjectCode/deployment.yml)**

- Expose the deployment by creatin a file called `service.yml` with the following entries: **[service.yml content](./FinalProjectCode/service.yml)**

---
### Step 11: Argocd Installation

10.1 **Create a Namespace for Argo CD**

```bash
kubectl create namespace argocd
```
10.2 **Install Argo CD**

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

10.3 **Expose the Argo CD Server by LoadBalancer**

-  Patch the ArgoCD server service
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
- Get the External URL
```bash
kubectl get svc -n argocd argocd-server
```
- Look for the EXTERNAL-IP column and access ArgoCD at:
```
https://<EXTERNAL-IP>
```
![image](https://github.com/user-attachments/assets/edc0b527-231a-47ea-ad84-1bb93b521b22)

10.4 **Login to Argo CD**

- Retrieve the initial admin password:

  ```bash
  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
  ```
- Login with the username `admin` and the password retrieved earlier.
---
### Step 12: Argocd Configuration 
- Create a File called `application.yml` and insert the following entries: **[application.yml content](./application.yml)**

- Apply the Argocd configuration

  ```bash
  kubectl apply -f application.yml
  ```
- Expose the deployment to the internet to be able to access it through internet

  ```bash
  kubectl port-forward service/ivolve-app-service 7070:80 -n ivolve-namespace
  ```

- Navigate to the UI of the Argocd

  ![image](https://github.com/user-attachments/assets/afe2e1ce-2f43-48dc-9cef-a0380263dcdc)

- You can now access the application using the following url http://localhost:7070

  ![image](https://github.com/user-attachments/assets/c1ff1502-9dfc-4fe2-b6d3-267e19704f0b)

---
