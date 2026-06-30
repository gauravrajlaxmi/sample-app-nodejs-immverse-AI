# sample-app-nodejs-immverse-AI
# 🚀 Node.js CI/CD Pipeline with Jenkins + Docker + AWS EKS + Monitoring'




JENKINS URL :
http://98.81.191.63:8080/


Complete CI/CD deployment pipeline for a Node.js application using:

- Node.js + Express
- Docker
- Jenkins
- Docker Hub
- AWS EKS
- Kubernetes
- Prometheus
- Grafana

---

# Project Structure

```bash
sample-cicd-app/
│
├── script/
│   ├── install-packages.sh
│   └── install-monitoring.sh
│
├── Dockerfile
├── Jenkinsfile
├── .env.example
├── package.json
├── app.js
├── deployment.yaml
├── service.yaml
├── prometheus.yml
├── README.md
```

---

# Step 0 — Launch EC2

Launch Ubuntu EC2.

Connect:

```bash
ssh -i key.pem ubuntu@<EC2-PUBLIC-IP>
```

Update:

```bash
sudo apt update
sudo apt upgrade -y
```

Clone:

```bash
git clone https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI.git

cd sample-app-nodejs-immverse-AI
```

---

# Step 1 — Install Packages Using Script
<img src="https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI/blob/main/screenshots/Screenshot%202026-05-24%20213822.png?raw=true" alt="">


Give permission:

```bash
chmod +x script/*.sh
```

Run:

```bash
./script/install-packages.sh
```

Installs:

- Docker
- Jenkins
- Node.js
- AWS CLI
- kubectl
- eksctl
- Helm
- Git

Verify:

```bash
docker --version
jenkins --version
node -v
aws --version
kubectl version --client
```

Enable Docker for Jenkins:

```bash
sudo usermod -aG docker jenkins

sudo systemctl restart docker

sudo systemctl restart jenkins
```

Open Jenkins:

```text
http://<EC2-IP>:8080
```

---

# Step 2 — Create Node.js Application

## package.json

```json
{
  "name":"sample-app",
  "version":"1.0.0",
  "scripts":{
      "start":"node app.js",
      "test":"echo Testing Passed"
  },
  "dependencies":{
      "express":"^4.18.2"
  }
}
```

---

## app.js

```javascript
const express=require("express");

const app=express();

app.get("/",(req,res)=>{
res.send("CI/CD Deployment Successful");
});

app.listen(3000,()=>{
console.log("Running");
});
```

---

## .env.example

```env
PORT=3000
```

Install:

```bash
npm install
```

Push:

```bash
git add .

git commit -m "Initial application"

git push origin main
```

---

# Step 3 — Dockerize Application

## Dockerfile

```dockerfile
FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm","start"]
```

Build:

```bash
docker build -t sample-app .
```

Run:

```bash
docker run -p 3000:3000 sample-app
```

Verify:

```text
http://localhost:3000
```

Output:

```text
CI/CD Deployment Successful


```
<img src="https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI/blob/main/screenshots/Screenshot%20(412).png" alt="">


---

# Step 4 — Jenkins Setup



Install Plugins:

- Docker
- Git Plugin
- Docker Pipeline Plugin
- Pipeline
- Kubernetes CLI
- AWS Credentials

Open:

```text
Manage Jenkins
→ Plugins
```

---

# Step 5 — Configure Jenkins Credentials

Open:

```text
Manage Jenkins
→ Credentials
→ Global
```
<img src="https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI/blob/main/screenshots/Screenshot%202026-05-24%20214514.png?raw=true" alt="">
Create:

### GitHub

```text
ID → git-cred
```

### Docker Hub

```text
ID → dockerhub
```

### AWS

```text
ID → aws-creds
```

---

# Step 6 — Jenkins Pipeline

## Jenkinsfile

```groovy
pipeline {

agent any

environment {

IMAGE="your-dockerhub/sample-app"

AWS_DEFAULT_REGION="us-east-1"

CLUSTER_NAME="sample-cluster-cicd-AI-new"

}

stages {

stage('Checkout') {

steps {

git branch:'main',

credentialsId:'git-cred',

url:'<repo-url>'

}

}

stage('Build') {

steps {

sh 'docker build -t $IMAGE:$BUILD_NUMBER .'

}

}

stage('Test') {

steps {

sh 'npm install'

sh 'npm test'

}

}

stage('Docker Push') {

steps {

withCredentials([

usernamePassword(

credentialsId:'dockerhub',

usernameVariable:'USER',

passwordVariable:'PASS'

)

]) {

sh '''

echo $PASS | docker login -u $USER --password-stdin

docker push $IMAGE:$BUILD_NUMBER

docker tag $IMAGE:$BUILD_NUMBER $IMAGE:latest

docker push $IMAGE:latest

'''

}

}

}

stage('Deploy To EKS') {

steps {

withCredentials([

[

$class:

'AmazonWebServicesCredentialsBinding',

credentialsId:'aws-creds'

]

]) {

sh '''

aws eks update-kubeconfig \
--region $AWS_DEFAULT_REGION \
--name $CLUSTER_NAME

kubectl apply -f deployment.yaml

kubectl apply -f service.yaml

kubectl rollout status deployment/sample-app

'''

}

}

}

}

}
```
<img src="https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI/blob/main/screenshots/Screenshot%202026-05-24%20215046.png?raw=true" alt="">
---

# Step 7 — Create EKS Cluster

```bash
eksctl create cluster \
--name sample-cluster-cicd-AI-new \
--region us-east-1 \
--nodegroup-name ng \
--node-type t3.medium \
--nodes 1 \
--nodes-min 1 \
--nodes-max 2 \
--managed
```

Configure:

```bash
aws eks update-kubeconfig \
--region us-east-1 \
--name sample-cluster-cicd-AI-new
```

Verify:

```bash
kubectl get nodes
```
<img src="https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI/blob/main/screenshots/Screenshot%20(405).png?raw=true" alt="">
---

# Step 8 — Deploy Application

```bash
kubectl apply -f deployment.yaml

kubectl apply -f service.yaml
```

Check:

```bash
kubectl get pods

kubectl get svc
```

---

<img src="https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI/blob/main/screenshots/Screenshot%202026-05-24%20214652.png?raw=true" alt="">

# Step 9 — Install Monitoring

Run:

```bash
./script/install-monitoring.sh
```

Or manually:

```bash
kubectl apply -f \
https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

helm repo add prometheus-community \
https://prometheus-community.github.io/helm-charts

helm repo update

helm install monitoring \
prometheus-community/kube-prometheus-stack \
-n monitoring \
--create-namespace
```

Expose Grafana:

```bash
kubectl patch svc monitoring-grafana \
-n monitoring \
-p '{"spec":{"type":"LoadBalancer"}}'
```

Expose Prometheus:

```bash
kubectl patch svc monitoring-kube-prometheus-prometheus \
-n monitoring \
-p '{"spec":{"type":"LoadBalancer"}}'
```

Verify:

```bash
kubectl get svc -n monitoring
```

---

# Pipeline Flow

```text
GitHub
↓

Jenkins
↓

Docker Build
↓

Docker Hub
↓

AWS EKS
↓

Prometheus
↓

Grafana
```

---

# Security

- Store credentials in Jenkins Credentials
- Never commit secrets
- Use IAM roles where possible
- Rotate tokens regularly

- =================================================================================================================\

- ASSigmnet :1
Request Flow
User enters website URL.
DNS resolves ALB endpoint.
Request reaches Application Load Balancer.
ALB checks Target Group.
Target Group identifies healthy EC2 instances.
Request forwarded to EC2-1 or EC2-2.
Nginx serves webpage.
Data stored on EBS if needed.
Response sent back through ALB to user.



Part 1 – IAM
1. Why should the root account not be used for daily activities?

The root account has unrestricted access to all AWS resources. Using it for daily activities increases the risk of accidental changes and security breaches. AWS recommends using IAM users with the minimum required permissions and reserving the root account for account-level tasks only.

2. Difference between IAM User and IAM Role?

An IAM User is a permanent identity created for a person or application with long-term credentials. An IAM Role is a temporary identity that AWS services or users can assume to obtain temporary permissions without storing long-term credentials.

3. Why are Groups preferred over assigning permissions directly to users?

Groups simplify permission management by allowing permissions to be assigned once to the group instead of individually to each user. This ensures consistent access control and reduces administrative effort.

Part 2 – VPC
1. Why create a custom VPC instead of using the default VPC?

A custom VPC provides better control over networking, IP address ranges, security, routing, and resource isolation. It is more suitable for production environments than the default VPC.

2. Why are multiple Availability Zones used?

Multiple Availability Zones improve high availability and fault tolerance. If one Availability Zone becomes unavailable, resources in another Availability Zone continue serving the application.

3. What happens if the Internet Gateway is detached?

Instances in public subnets lose internet connectivity. Users cannot access the website, and SSH connections from the internet will fail.

4. What happens if the default route is removed?

Without the default route (0.0.0.0/0) pointing to the Internet Gateway, traffic cannot reach the internet. The EC2 instances become inaccessible from outside the VPC.

Part 3 – Security Groups
1. What is the purpose of a Security Group?

A Security Group acts as a virtual firewall that controls inbound and outbound network traffic for EC2 instances.

2. Difference between Security Group and NACL?

A Security Group is attached to EC2 instances, is stateful, and allows only allow rules. A Network ACL (NACL) is attached to subnets, is stateless, and supports both allow and deny rules.

3. Why should SSH not be open to the entire internet in production?

Allowing SSH from anywhere increases the risk of unauthorized access and brute-force attacks. In production, SSH access should be restricted to trusted IP addresses.

Part 4 – EC2
1. Why are the servers placed in separate Availability Zones?

Placing servers in different Availability Zones ensures high availability. If one Availability Zone fails, the other server continues serving user requests.

2. What happens if one Availability Zone becomes unavailable?

The server in that Availability Zone becomes unavailable, but the Application Load Balancer routes traffic to the healthy server in the other Availability Zone, keeping the application available.

Part 5 – EBS
1. Why does the file remain after reboot?

The file remains because EBS is persistent storage. Data stored on an EBS volume is retained even after the EC2 instance is rebooted.

2. Difference between RAM and EBS?

RAM is temporary memory used while the system is running, and its contents are lost after shutdown or reboot. EBS is persistent storage that permanently stores data until it is deleted.

3. What happens if the EBS volume is detached?

The data stored on the EBS volume remains intact, but the EC2 instance cannot access it until the volume is attached and mounted again.

Part 6 – Target Groups
1. What is the purpose of a Target Group?

A Target Group is a collection of backend resources, such as EC2 instances, that receive traffic from a Load Balancer.

2. Why does a Load Balancer use Target Groups?

The Load Balancer uses Target Groups to distribute traffic only to healthy instances and to perform health checks before forwarding requests.

Part 7 – Application Load Balancer
1. Why is a Load Balancer required?

A Load Balancer distributes incoming traffic across multiple EC2 instances, improving availability, scalability, and fault tolerance.

2. What happens if one EC2 instance fails?

The Load Balancer detects the failed instance through health checks and automatically routes traffic only to the remaining healthy instance.

3. What is the purpose of Health Checks?

Health Checks monitor the status of registered EC2 instances. The Load Balancer sends traffic only to instances that pass the health checks.

Part 8 – Failure Testing
1. Why was the application still accessible?

The application remained accessible because the Application Load Balancer automatically routed all requests to the healthy EC2 instance after detecting that EC2-1 was unhealthy.

2. Which AWS component handled the failure?

The Application Load Balancer (ALB) handled the failure using Target Group Health Checks to stop routing traffic to the failed instance.

Part 9 – Auto Scaling Group
1. What is Desired Capacity?

Desired Capacity is the number of EC2 instances that the Auto Scaling Group attempts to keep running at all times. If the number of running instances drops below this value, the Auto Scaling Group launches new instances automatically.

2. What is the purpose of a Launch Template?

A Launch Template is a predefined configuration used to launch EC2 instances. It includes settings such as the AMI, instance type, key pair, Security Group, storage, and User Data.

3. How does Auto Scaling improve availability?

Auto Scaling improves availability by automatically replacing failed EC2 instances and maintaining the desired number of running instances. This minimizes downtime and keeps the application available.

Troubleshooting Challenges
Challenge 1: Delete the route 0.0.0.0/0. Identify the issue and fix it.

Issue: EC2 instances lose internet connectivity, making the website and SSH inaccessible.

Fix: Add the default route 0.0.0.0/0 pointing to the Internet Gateway in the Route Table.

Challenge 2: Remove Port 80 from the Security Group. Identify the issue and fix it.

Issue: HTTP traffic is blocked, the website becomes inaccessible, and the Load Balancer health checks fail.

Fix: Add an inbound rule allowing HTTP (Port 80) from the required source (typically 0.0.0.0/0 for a public website).

Challenge 3: Stop one EC2 instance. Explain why the application still works.

The Application Load Balancer detects the unhealthy instance through health checks and routes all incoming traffic to the remaining healthy EC2 instance.
