## Table of Content

- [Ansible Structure](#ansible-structure)

- [Prequesites](#prequesites)

  - [1. Install Ansible on the Control Node](#1-install-ansible-on-the-control-node)
  
  - [2. Configure the Inventory File](#2-configure-the-inventory-file)
  
  - [3. Verify Ansible Connectivity](#3-verify-ansible-connectivity)
  
- [Notes:](#notes)

- [Steps:](#steps)

  - [1. Create the required `roles`](#1-create-the-required-roles)
  
  - [2. Installing necessary packages `Preinstall_role`](#2-start-by-installing-necessary-packages-preinstall_role)
  
  - [3. Install Docker `Docker_role`](#3-install-docker-docker_role-and-dont-forget-to-define-the-handlers)
  
  - [4. Install Jenkins `Jenkins_role`](#4-install-jenkins-jenkins_role-and-dont-forget-to-define-the-handlers)
  
  - [5. Install SonarQube `SonarQube_role`](#5-install-sonarqube-sonarqube_role-and-pay-attention-to-the-variables-and-also-the-handlers)
  
- [Notes:](#notes-1)

- [Installing and Configuring PostgreSQL.](#installing-and-configuring-postgresql)

- [Installing and Configuring SonarQube](#installing-and-configuring-sonarqube)

- [Setup systemD Service](#setup-systemd-service)

## Ansible Structure 

![image](https://github.com/user-attachments/assets/494eceed-b387-4b09-a2cf-889a1d50504a)

## Prequesites 

### 1. Install Ansible on the Control Node  

1.1 **Install Python and pip**
- Ensure Python and pip are installed on your system. Run the following commands:
```bash
sudo apt update
sudo apt install python3 python3-pip python3.12-venv -y
```
1.2 **Add the Ansible PPA**
```bash
sudo add-apt-repository --yes --update ppa:ansible/ansible
```
1.3 **Create a virtual environment**:  
```bash
python3 -m venv ansible-env
```

1.4. **Activate the virtual environment**:  
```bash
source ansible-env/bin/activate
```
1.5 **Install Ansible Core inside the virtual environment**:
```bash
pip install ansible
```
- Each time you will use ansible you will need to activate the virtual environment using the command in step 1.4.

- It’s a good practice to use a Python virtual environment to isolate dependencies.
---

### 2. Configure the Inventory File  

2.1. **Install Required Python Libraries**
-The AWS inventory plugin requires the boto3 library:
```bash
pip install boto3 botocore
```

2.2. **Create the Dynamic Inventory Configuration File**:  
```
nano aws_ec2.yml
```
- **Add the following content [aws_ec2.yml](./aws_ec2.yml) to configure the plugin:**

2.3. **Configure Ansible Configuration File**:
- Create `ansible.cfg` file.

- Move the private key of your instances to the same 
path that you will insert in the configuration file.

- Make sure of the user that you will ssh to using ansible.
```bash
touch ansible.cfg
```
- **Insert the following content [ansible.cfg](./ansible.cfg)**
---

### 3. Verify Ansible Connectivity  


3.2. **Ping the managed host to verify connectivity**:  
```bash
ansible all -m ping
```
![image](https://github.com/user-attachments/assets/3db212db-99c3-4dd6-b04a-9246466c444f)

---

## Notes:

- In case you have a problem in ssh connectivity use the following command to troubleshoot the ssh connectivity
```bash
ansible all -m ping -vvvv
```
---
## Steps:

### 1. Create the required `roles`

```bash
mkdir -p roles/{Preinstall/tasks,Docker/{tasks,handlers},Jenkins/{tasks,handlers},SonarQube/{tasks,handlers,vars}}
touch roles/{Preinstall/tasks,Docker/{tasks,handlers},Jenkins/{tasks,handlers},SonarQube/{tasks,handlers,vars}}/main.yml
```
### 2. Start by Installing necessary packages [Preinstall_role](./roles/Preinstall/tasks/main.yml).

### 3. Install Docker [Docker_role](./roles/Docker/tasks/main.yml) and don't forget to define the handlers.

### 4. Install Jenkins [Jenkins_role](./roles/Jenkins/tasks/main.yml) and don't forget to define the handlers.

### 5. Install SonarQube [SonarQube_role](./roles/SonarQube/tasks/main.yml) and pay attention to the variables and also the handlers.

- Now you can run the `playbook.yml`
```bash
ansible-playbook playbook.yml
```
---
## Notes:
- Installing SonarQube can be challenging so you can start installing it manually using the following steps first then you can automate the process using ansible later.

### Installing and Configuring PostgreSQL.

- Install PostgreSQL.
```bash
sudo apt install postgresql-14 -y
```
- Enable the database server to start automatically on reboot.
  
```bash
sudo systemctl enable postgresql
```
- Start the database server.

```bash
sudo systemctl start postgresql
```
- Ensure PostgreSQL is listening on * by adding the following line to `/etc/postgresql/14/main/postgresql.conf`

```bash
listen_addresses='*'
```
- Add a new configuration to `/etc/postgresql/14/main/pg_hba.conf`
  
```bash
host    all             all             0.0.0.0/0                md5
host    all             all             ::/0                     md5
```
- Restart the PostgreSQL service

```bash
sudo systemctl restart postgresql
```
- Change the default PostgreSQL password.

```bash
sudo passwd postgres
```
- Switch to the postgres user.
  
```bash
su — postgres
```

- Create a user named sonar.
  
```bash
createuser sonar
```
- Log in to PostgreSQL.

```bash
psql
```
- Set a password for the sonar user.
  
```bash
ALTER USER sonar WITH ENCRYPTED password ‘my_strong_password’;
```
- Create a sonarqube database and set the owner to sonar.
  
```bash
CREATE DATABASE sonarqube OWNER sonar;
```
- Grant all the privileges on the sonarqube database to the sonar user.

```bash
GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;
```
- Exit PostgreSQL.
  
```bash
\q
```
- Return to your non-root sudo user account.

```bash
exit
```
### Installing and Configuring SonarQube
**Check the required packages before installing here [Preinstall_role](./roles/Preinstall/tasks/main.yml)**

- `SonarQube` uses `Elasticsearch` to store its indices in an MMap FS directory. It requires some changes to the system defaults.
- Add the following lines to `/etc/sysctl.conf`

```bash
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
```
- Download the SonarQube distribution files.

```bash
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.6.1.59531.zip
```
- Unzip the downloaded file.

```bash
sudo unzip sonarqube-9.6.1.59531.zip
```
- Move the unzipped files to /opt/sonarqube directory

```bash
sudo mv sonarqube-9.6.1.59531 /opt
```

- Create a dedicated user and group for SonarQube, which can not run as the root user.

- Create a sonar group.

```bash
sudo groupadd sonar
```
- Create a sonar user and set /opt/sonarqube-9.6.1.59531 as the home directory.

```bash
sudo useradd -d /opt/sonarqube-9.6.1.59531 -g sonar sonar
```
- Grant the sonar user access to the /opt/sonarqube directory.
  
```bash
sudo chown sonar:sonar /opt/sonarqube-9.6.1.59531 -R
```
- Configure SonarQube

- Edit the SonarQube configuration file.
  
```bash
sudo nano /opt/sonarqube-9.6.1.59531/conf/sonar.properties
```
- Find the following lines:
```bash
#sonar.jdbc.username=

#sonar.jdbc.password=
```
- Uncomment the lines, and add the database user and password you created in Step 2.
```bash
sonar.jdbc.username=sonar

sonar.jdbc.password=my_strong_password
```
- Below those two lines, add the sonar.jdbc.url.
  
```bash
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
```
- Save and exit the file.

### Setup systemD Service  

- Create a systemd service file to start SonarQube at system boot.
  
```bash
sudo nano /etc/systemd/system/sonar.service
```
- Paste the following lines to the file:

```bash
[Unit]

Description=SonarQube service

After=syslog.target network.target

[Service]

Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86–64/sonar.sh start

ExecStop=/opt/sonarqube/bin/linux-x86–64/sonar.sh stop

User=sonar

Group=sonar

Restart=always

LimitNOFILE=65536

LimitNPROC=4096

[Install]

WantedBy=multi-user.target
```
- Save and exit the file.

- Enable the SonarQube service to run at system startup.

```bash
sudo systemctl enable sonar
```
- Start the SonarQube service.
```bash
sudo systemctl start sonar
```
- Reload Systemd

```bash
sudo systemct daemon-reload
```

**Access SonarQube in a web browser at your server’s IP address on port 9000.**

```bash
http://<Your-Server-IP>:9000
```

![image](https://github.com/user-attachments/assets/41932821-ec66-49f7-91af-96a19ece9bdf)

- Insert `admin` for both username and password

![image](https://github.com/user-attachments/assets/ddd11575-fa45-49ed-a857-50da20e9e4ab)
