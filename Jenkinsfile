pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ssanthosh2k3/nginx-san"
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        CHART_PATH = "charts/nginx-app"
        RELEASE_NAME = "nginx-san"
        NAMESPACE = "default"
        AUTO_COMMIT_MESSAGE = "Update image tag to ${DOCKER_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/ssanthosh2k3/eks-task-2'
                script {
                    def lastCommitMessage = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    echo "Last commit message: '${lastCommitMessage}'"
                    if (lastCommitMessage == AUTO_COMMIT_MESSAGE) {
                        echo "✅ Build triggered by auto-commit. Skipping to prevent loop."
                        error("Skipping build due to automated commit from Jenkins.")
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        sh """
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
                    }
                }
            }
        }

        stage('Update Helm Values') {
            steps {
                script {
                    def valuesFile = "${CHART_PATH}/values.yaml"
                    sh """
                        sed -i 's|tag:.*|tag: "${DOCKER_TAG}"|' ${valuesFile}
                        git config --global user.email "jenkins@localhost"
                        git config --global user.name "Jenkins"
                        git add ${valuesFile}
                        git commit -m "${AUTO_COMMIT_MESSAGE}" || echo "No changes to commit"
                        git push origin main || echo "No push needed"
                    """
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up unused Docker images on Jenkins agent"
            sh "docker image prune -af"
        }

        failure {
            echo "❌ Build or deployment failed."
        }

        success {
            echo "✅ Build and deployment succeeded!"
        }
    }
}
