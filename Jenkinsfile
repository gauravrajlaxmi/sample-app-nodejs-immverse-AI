pipeline {

agent any

environment {

IMAGE="dockerhub-user/sample-app"

}

stages {

stage('Checkout') {

steps {
git branch: 'main',
url: 'https://github.com/user/sample-cicd-app.git'
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

stage('Push Image') {

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

stage('Deploy') {

steps {

sh '''
kubectl apply -f deployment.yaml

kubectl apply -f service.yaml
'''

}

}

}

}
