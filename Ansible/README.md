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
  instance-state-name: running     # Group by tags
hostnames:
  - tag:Name          # Use the Name tag as the hostname
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



2.2. **Add managed hosts to the inventory**:  
    ```
    [$GROUP]
    $SERVER_1
    $SERVER_2

    [$GROUP:vars]
    ansible_user=$SERVER_USER
    ansible_ssh_private_key_file= $KEY_PATH
    ```
    ![image](https://github.com/user-attachments/assets/3964b82d-1007-4c3f-817d-4bc775480216)

    - Replace `server1` and `server2` with your actual hostnames or IPs.  
    - Replace `ansible_user=dumb` with your username.
    
3. **Add ansible configuration file**:  
  
    ```bash
    vim ansible.cfg
    ```
    - Add the following entry
    ```
    [defaults]
    inventory= ./inventory
    remote_user= $USER
    ask_pass= false
    

    [Privilege escalation]
    become=true
    become_method=sudo
    become_user=root
    become_ask_pass=false

    ```
    ![image](https://github.com/user-attachments/assets/4ec3fc9c-5e21-48b7-bf21-daa195b4b2ee)

    - Replace `remote_user` with your actual hostname user.  

---

### 3. Verify Ansible Installation  

3.1. **Check the Ansible version**:  
    ```bash
    ansible --version
    ```
    ![image](https://github.com/user-attachments/assets/f4a5cea1-caf9-479b-822f-29e72209a69b)

3.2. **Ping all managed hosts to verify connectivity**:  
    ```bash
    ansible all -m ping
    ```
    ![image](https://github.com/user-attachments/assets/e82733de-cfda-4ee2-9f40-614ee1071a78)

---

