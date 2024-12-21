## Ansible Structure 

![image](https://github.com/user-attachments/assets/6230abc7-8c20-4020-9b23-424e2699b4b1)

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
- Each time you will use ansible you will need to activate the virtual environment.
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
- Add the following content to `aws_ec2.yml` file to configure the plugin:
```yaml
plugin: aws_ec2
regions:
  - us-east-1        # Replace with your AWS region
filters:
  instance-state-name: running
  tag:Name: ivolve-ec2 #Filter by the tag of the ec2 instance
```

2.3. **Configure Ansible Configuration File**:
- Create `ansible.cfg` file.
- Move the private key of your instances to the same path in the configuration file.
- Make sure of the user that you will ssh to using ansible.
```bash
touch ansible.cfg
```
- Insert the following enty to `ansible.cfg` file
```ini
[defaults]
inventory = aws_ec2.yml
ansible_user = ec2-user
private_key_file = ~/Graduation_Project/Ansible/Slave.pem

[inventory]
enable_plugins = amazon.aws.aws_ec2, aws_ec2, yaml, ini, host_list

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```
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
mkdir -p roles/{Preinstall/tasks,Git/tasks,Docker/tasks,Java/tasks,Jenkins/tasks,SonarQube/tasks}
touch roles/{Preinstall/tasks,Git/tasks,Docker/tasks,Java/tasks,Jenkins/tasks,SonarQube/tasks}/main.yml
```
![image](https://github.com/user-attachments/assets/0a196d72-55c0-49f2-882d-d6285dcb2335)

