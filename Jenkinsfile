pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = '054037114964.dkr.ecr.us-east-1.amazonaws.com'
        DOCKER_REPO = 'eyego/node-web-app'
    }
    
    stages {
        stage('Build') {
            steps {
                dir('src/') {
                    sh "docker build -t eyego-app:lts ."
                }
            }
        }
        stage('Push') {
            steps {
                sh "docker tag eyego-app:lts ${DOCKER_REGISTRY}/${DOCKER_REPO}:${BUILD_NUMBER}"
                withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${DOCKER_REGISTRY}"
                }
                sh " docker push ${DOCKER_REGISTRY}/${DOCKER_REPO}:${BUILD_NUMBER}"
            }
        }
        stage('Deploy') {
            steps {
                dir('deployment/') {
                    withKubeConfig(credentialsId: 'kubeconfig') {
                        sh "kubectl apply -f namespace.yml"
                        sh "kubectl apply -f service.yaml"
                        sh "envsubst < deployment.yaml | kubectl apply -f -"
                    }
                }
            }
        }
    }
}