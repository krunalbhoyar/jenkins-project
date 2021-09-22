## task:
jenkins master and 2 worker nodes, git checkout, run test cases, take o/p in sonarqube , if quality gates pass then further action will perform otherwise pipeline should abort, if pass then build docker image and deploy to worker nodes of jenkins,
once the pipeline trigger the take the backend db (mysql, mongo) output in s3 bucket, then pipeline proceed 

Install jenkins, git, docker, docker-compose at master node:
````
vim install.sh.sh
````
#!/bin/bash
#install git
sudo yum update -y
sudo yum install git -y

#install docker and docker-compose
sudo amazon-linux-extras install docker -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Install Jenkins
sudo amazon-linux-extras install epel -y
sudo yum install java-1.8.0-openjdk -y
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.191.b12-1.el7_6.x86_64
echo $JAVA_HOME
export JAVA_HOME
PATH=$PATH:$JAVA_HOME
source ~/.bash_profile
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo chkconfig jenkins on
 ________________

add sonarqube docker-compose.yaml file

docker-compose up -d
now browse (Public IPv4 address:9000)
username: admin
password: admin

Follow this video to add node https://www.youtube.com/watch?v=ucctWFyNFpY

# +++++Setup jenkins slave1+++++
Now launch another ec2 instance 

install java
sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install java-1.8.0-openjdk -y
java -version

install docker:
sudo amazon-linux-extras install docker -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

sudo useradd jenkins-slave1
sudo su - jenkins-slave1
ssh-keygen -t rsa -N "" -f /home/jenkins-slave1/.ssh/id_rsa
cd .ssh     (you will get 'id_rsa'  'id_rsa.pub')
cat id_rsa.pub > authorized_keys
chmod 700 authorized_keys
cat id_rsa

Now we will copy authorized_keys to master node "known_hosts" folder
Now connect to master cli

# ++++++Setup Jenkins Master++++++
sudo mkdir -p /var/lib/jenkins/.ssh
cd /var/lib/jenkins/
ls -la
sudo chmod 777 .ssh
ssh-keyscan -H 172.31.19.47 >> /var/lib/jenkins/.ssh/known_hosts     (this ip is SLAVE_NODE_Private_ip)
cd .ssh
sudo chown jenkins:jenkins known_hosts
sudo chmod 700 known_hosts
__________________________________________
Now launch jenkins dashboard with port 8080

# add Slave Node 1 at jenkins dashboard
go to manage jenkins > manage nodes and clouds > you will get master node
click on new node: 
Node name: slave1
tikk Permanent Agent > OK

Name: slave1
Description: slave node for aws jenkins
Number of executors: 5
Remote root directory: /home/jenkins-slave1
Labels: slave1
Usage: Use this node as much as possible
Launch method: Launch agents via SSH
Host: private ip of slave EC2 instance
Credentials: 
>>add > Jenkins> Kind> SSH Username with private key
>>ID: jenkins-slave1
>>Description: jenkins-slave1
>>Username: jenkins-slave1
>>Private Key: Enter directly > Add > paste the contents of 'id_rsa' key file you created for slave > Add 
Choose that credentials > save

[to get 'id_rsa' follow the steps]
At slave1 cli
sudo su - jenkins-slave1
cat /home/jenkins-slave1/.ssh/id_rsa

# add Slave Node 2

follow the above steps

--------------------------

open jenkins dashboard and install plugins:  
1) Docker pipeline plugin  
2) sonarqube scanner

1)Install sonarqube scanner plugin: go to manage jenkins > manage plugins> available> search for "sonarqube scanner" and install it and click on restart
2) go to manage jenkins> configure system> SonarQube servers> Tikk on Environment variables Enable injection > name: sonarqube >Server URL: http://20.20.4.41:9000   and dont add authentication token>save
3)go to manage jenkins> Global tool configuration> SonarQube Scanner installation> Name: sonarqube (give same name to above also)> Tikk Install automatically> Save
4) in jenkins create new pipeline job

to abort quality gate pipeln check: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-jenkins/

Quality gate https://discuss.devopscube.com/t/waitforqualitygate-in-jenkins-pipeline/1805
