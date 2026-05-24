#!/bin/bash
sudo apt update

sudo apt install fontconfig openjdk-21-jre -y
java -version

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install jenkins -y

#You can enable the Jenkins service to start at boot with the command:

sudo systemctl enable jenkins
#You can start the Jenkins service with the command:

sudo systemctl start jenkins
#You can check the status of the Jenkins service using the command:

sudo systemctl status jenkins
