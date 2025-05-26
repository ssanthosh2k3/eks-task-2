pipeline {
  agent any

  environment {
    IMAGE_NAME = "santhoshadmin/nginx-app"
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    VALUES_FILE = "charts/nginx-app/values.yaml"
  }

  options {
    skipDefaultCheckout()
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/ssanthosh2k3/eks-task-2.git'
        script {
          // Get last commit message
          def lastCommitMsg = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
          echo "Last commit message: '${lastCommitMsg}'"
          
          // Skip build if commit was triggered by Jenkins updating the image tag
          if (lastCommitMsg.contains("Update image tag")) {
            echo "Build triggered by automated commit. Skipping build to avoid loop."
            currentBuild.result = 'SUCCESS'
            error("Skipping build due to automated commit from Jenkins.")
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          docker.build("${IMAGE_NAME}:${IMAGE_TAG}", ".")
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${IMAGE_NAME}:${IMAGE_TAG}
          """
        }
      }
    }

    stage('Update Helm Values') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'git-hub', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
            sh """
              sed -i 's|tag: .*|tag: "${IMAGE_TAG}"|' ${VALUES_FILE}
              git config user.name "jenkins"
              git config user.email "jenkins@local"
              git add ${VALUES_FILE}
              git commit -m "Update image tag to ${IMAGE_TAG}"
              git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/ssanthosh2k3/eks-task-2.git main
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Image built and pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
      echo "✅ values.yaml updated and pushed to GitHub"
    }
    failure {
      echo "❌ Build or update failed"
    }
    always {
      echo "🧹 Cleaning up unused Docker images on Jenkins agent"
      sh 'docker image prune -af || true'
    }
  }
}
