# sample-app-nodejs-immverse-AI
# 🚀 Node.js CI/CD Pipeline with Jenkins + Docker + AWS EKS + Monitoring'

APPLICATION URL :
http://a71401447269f47648d409b28debb7aa-1628446870.us-east-1.elb.amazonaws.com/

GRAFANA URL :
http://ac6f20ea48ccf47dc8af055c0adda28d-585402200.us-east-1.elb.amazonaws.com/


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
<img src="https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI/blob/main/screenshots/Screenshot%202026-05-24%20214823.png?raw=true" alt="">

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
