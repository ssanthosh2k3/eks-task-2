pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'santhoshadmin/nginx-app'
        GIT_CREDENTIALS = 'git-hub'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        HELM_REPO = 'https://github.com/ssanthosh2k3/helm-eks.git'
        HELM_CHART_PATH = 'nginx-app'
        DOCKER_REPO = 'https://github.com/ssanthosh2k3/eks-task-2.git'
        NEW_TAG = '' // will be dynamically set
    }

    stages {
        stage('Checkout Docker App') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: 'refs/heads/main']],
                          userRemoteConfigs: [[
                            url: env.DOCKER_REPO,
                            credentialsId: env.GIT_CREDENTIALS
                          ]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Create a new tag with timestamp or git commit hash
                    def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    NEW_TAG = "build-${commitHash}"
                    echo "New Docker Tag: ${NEW_TAG}"

                    docker.withRegistry('', env.DOCKERHUB_CREDENTIALS) {
                        def appImage = docker.build("${DOCKER_IMAGE}:${NEW_TAG}")
                        appImage.push()
                    }
                }
            }
        }

        stage('Cleanup Docker Images') {
            steps {
                script {
                    sh "docker rmi ${DOCKER_IMAGE}:${NEW_TAG} || true"
                    sh "docker image prune -f"
                }
            }
        }

        stage('Update values.yaml with new image tag') {
    steps {
        dir('helm-chart/nginx-app') {
            script {
                // Update tag
                def valuesFile = 'values.yaml'
                def content = readFile(valuesFile)
                def updated = content.replaceAll(/tag: .*/, "tag: ${NEW_TAG}")
                writeFile(file: valuesFile, text: updated)

                sh "git config user.email 'jenkins@example.com'"
                sh "git config user.name 'Jenkins CI'"

                sh "git add ${valuesFile}"
                sh "git commit -m 'Update image tag to ${NEW_TAG} from Jenkins pipeline'"

                withCredentials([usernamePassword(credentialsId: env.GIT_CREDENTIALS, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh """
                        git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/ssanthosh2k3/helm-eks.git
                        git push origin main
                    """
                }
            }
        }
    }
}

        stage('Update values.yaml with new image tag') {
            steps {
                dir('helm-chart/nginx-app') {
                    script {
                        // Read values.yaml and replace tag
                        def valuesFile = 'values.yaml'
                        def content = readFile(valuesFile)
                        def updated = content.replaceAll(/tag: .*/, "tag: ${NEW_TAG}")
                        writeFile(file: valuesFile, text: updated)

                        sh "git config user.email 'jenkins@example.com'"
                        sh "git config user.name 'Jenkins CI'"

                        sh "git add ${valuesFile}"
                        sh "git commit -m 'Update image tag to ${NEW_TAG} from Jenkins pipeline'"
                        sh "git push origin main"
                    }
                }
            }
        }
    }
}
