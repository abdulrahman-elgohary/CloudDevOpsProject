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
---
### Step 2: Configure the Infrastructure using Ansible.

[Read the README for Ansible](./Ansible/README.md)
---
### Step 3: Jenkins Configuartion
3.1. **Access Jenkins Web Interface**

- Open a browser and navigate to http://<server-ip>:8080.

3.2. **Retrieve Admin Password**

```bash
sudo cat /var/jenkins_home/secrets/initialAdminPassword
```
3.3. **Complete the Setup Wizard**

- Use the retrieved password to log in.
- Install recommended plugins and set up your admin account.
  
![image](https://github.com/user-attachments/assets/c7156fb9-1d79-452d-b939-549d5af23c7e)

4.3 **Set Up a Jenkins Slave**

- **Launch another Server and Install Java.**
  
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
- Navigate to Manage Jenkins > Manage Nodes and Clouds > New Node.
- Name the node (e.g., k8s-slave) and choose Permanent Agent.

![image](https://github.com/user-attachments/assets/e797a31c-66ec-4933-a892-3fa01dd2246a)

- **Configure the Node Setting**

- Set the Remote Root Directory (e.g., /var/lib/jenkins/).
- Insert `my-slave` in the label section
- Provide the Launch Method (e.g., SSH).
- Choose the earlier created credentials for the ec2. 
- Create the node

![image](https://github.com/user-attachments/assets/1a999ebb-ed27-4e2b-8264-704dadba9824)

4.4 **Create the Shared Library**

- In Jenkins, configure the shared library:

- Navigate to `Manage Jenkins` > `Configure System` > `Global Trusted Pipeline Libraries`.
- Add a library name (e.g., shared-lib). (Pay attention to the name it should match the name of the repo)
- Point it to the Git repository containing the shared library.
- Choose the branch that hold your library
- Structure the shared library repository:
  
```bash
shared-lib/
└── vars/
    ├── gitCheckout.groovy
    ├── unitTest.groovy
    ├── buildJar.groovy
    ├── sonarQubeTest.groovy
    ├── buildandPushImage.groovy
    ├── deployOnK8s.groovy
```
4.5 **Install Sonnar Qube Scanner Plugin**

- Navigate to `Manage Jenkins` > `Plugins` > Search for `SonarQube Scanner for Jenkins` then install it.
- Navigate to `Manage Jenkins` > `Tools` > `SonarQube Scanner installations` > Give it a name `SonarQube`.

4.6 **Configure SonarQube Token**
- Navigate to `SonarQube` UI > `Administration` > `Update Token`.
  
  ![image](https://github.com/user-attachments/assets/2220208b-41ed-4914-8a7c-4c1b8cfde3fd)

- Navigate to `Manage Jenkins` > `System` >`SonarQube servers` add your environmental variables.

  ![image](https://github.com/user-attachments/assets/a7917ea1-e2ec-4d2d-9121-9773d5a9fc5f)
---  
### Step 4: Creating the functions inside the shared Library

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
- You will need to change the permissions of `/var/run/docker.sock` on the Jenkins-Agent.

```bash
sudo chmod 662 /var/run/docker.sock
```
---
### Step 5. Create Required Ceredentials
  
- **Create Credentials for the Jenkins to be able to access the dockerhub repo**
- `Manage Jenkins` >> `Credentials` >> `Add Credentials`
- Choose username and password credentials and name it `Docker-Hub`.
  
![image](https://github.com/user-attachments/assets/4848a79d-1a99-4775-a5de-2fc4a0bcf515)

### Step 6. Create an Ec2 and Install `Minikube` on it 
- Navigate to your `aws account` > `Ec2` > `Launch Ec2` > Choose `t2.large` size.
- SSH to the Ec2 and install Minikube like the following steps

![image](https://github.com/user-attachments/assets/9dfd1d45-2edc-42b4-8e4d-4b29b95d240f)

6.1 **Upate the system**
  
```bash
sudo apt update
```
6.2 **Install Docker**

```bash
sudo apt install -y docker.io
```
6.3 **Add the user system to the docker group**

```bash
sudo usermod -aG docker $USER
```
6.4 **Download and Install Minikube**

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
6.5 **Install Kubectl** 

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```
6.6 **Install Kubectl Compeletion**

```bash
sudo apt-get install -y bash-completion
source <(kubectl completion bash)
source ~/.bashrc
```
---
### Step 7: Install ArgoCd On the Minikube Cluster 

7.1 **Create a Namespace for Argo CD**

```bash
kubectl create namespace argocd
```
7.2 **Install Argo CD**

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

7.3 **Expose the Argo CD Server**

```bash
kubectl port-forward svc/argocd-server -n argocd 9090:443
```
- You can now access Argo CD at https://localhost:9090.

![image](https://github.com/user-attachments/assets/3118e78c-b357-4480-aa1f-86c09bedbc23)

7.4 **Login to Argo CD**

- Retrieve the initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```
- Login with the username `admin` and the password retrieved earlier.
