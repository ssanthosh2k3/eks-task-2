pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('dockerhub-creds')
        GIT_CREDENTIALS = credentials('git-hub')
        IMAGE_NAME = 'santhoshadmin/nginx-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: "${GIT_CREDENTIALS}", url: 'https://github.com/ssanthosh2k3/eks-task-2'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    IMAGE_TAG = "${BUILD_NUMBER}"
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh """
                        echo "${DOCKER_CREDENTIALS_PSW}" | docker login -u "${DOCKER_CREDENTIALS_USR}" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    """
                }
            }
        }

        stage('Update values.yaml') {
            steps {
                script {
                    sh """
                        sed -i 's|repository:.*|repository: ${IMAGE_NAME}|' charts/nginx-app/values.yaml
                        sed -i 's|tag:.*|tag: \\"${IMAGE_TAG}\\"|' charts/nginx-app/values.yaml
                    """
                }
            }
        }

        stage('Commit and Push changes') {
            steps {
                script {
                    sh """
                        git config user.email "jenkins@yourdomain.com"
                        git config user.name "Jenkins"
                        git add charts/nginx-app/values.yaml
                        git commit -m "Update image tag to ${IMAGE_TAG} [ci skip]" || echo "No changes to commit"
                        git push https://${GIT_CREDENTIALS_USR}:${GIT_CREDENTIALS_PSW}@github.com/ssanthosh2k3/eks-task-2.git HEAD:main
                    """
                }
            }
        }

        stage('Clean up Docker images') {
            steps {
                script {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
