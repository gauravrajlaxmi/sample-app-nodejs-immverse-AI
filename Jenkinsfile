pipeline {
    agent any

    environment {
        IMAGE="gauravrajlaxmi15/sample-app"
        AWS_DEFAULT_REGION="us-east-1"
        CLUSTER_NAME="sample-cluster-cicd-AI-new"
    }

    stages {

        stage('code Checkout') {
            steps {
                git branch: 'main',
                credentialsId: 'git-cred',
                url: 'https://github.com/gauravrajlaxmi/sample-app-nodejs-immverse-AI.git'
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
                    [$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds']
                ]) {

                    sh '''
                    aws eks update-kubeconfig \
                    --region $AWS_DEFAULT_REGION \
                    --name $CLUSTER_NAME

                    kubectl apply -f deployment.yml

                    kubectl apply -f service.yml

                    kubectl rollout status deployment/sample-app
                    '''
                }
            }
        }
    }
}

