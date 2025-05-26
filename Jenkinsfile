pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ssanthosh2k3/nginx-san"
        DOCKER_TAG = "${BUILD_NUMBER}"
        HELM_CHART_DIR = "charts/nginx-app"
        VALUES_FILE = "${HELM_CHART_DIR}/values.yaml"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/ssanthosh2k3/eks-task-2.git', branch: 'main'
                script {
                    def commitMessage = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    echo "Last commit message: '${commitMessage}'"
                    if (commitMessage.startsWith("Update image tag to")) {
                        echo "✅ Build triggered by auto-commit. Skipping to prevent loop."
                        currentBuild.result = 'SUCCESS'
                        return
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
                script {
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Update Helm Values') {
            steps {
                script {
                    sh "sed -i 's|tag: .*|tag: \"${DOCKER_TAG}\"|' ${VALUES_FILE}"
                    sh "git config user.email 'jenkins@example.com'"
                    sh "git config user.name 'Jenkins CI'"
                    sh "git add ${VALUES_FILE}"
                    sh "git commit -m 'Update image tag to ${DOCKER_TAG}' || echo 'No changes to commit'"
                    sh "git push origin main"
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up unused Docker images on Jenkins agent"
            sh "docker image prune -af || true"
        }
        success {
            echo "✅ Build and deployment steps completed successfully."
        }
        failure {
            echo "❌ Build or deployment failed."
        }
    }
}
