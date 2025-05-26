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
          // Use GitHub credentials for authenticated push
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
  }
}
