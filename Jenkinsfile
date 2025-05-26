pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'santhoshadmin/nginx-app'
        GIT_CREDENTIALS = 'git-hub'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        HELM_REPO = 'https://github.com/ssanthosh2k3/helm-eks.git'
        HELM_CHART_PATH = 'nginx-app'
        DOCKER_REPO = 'https://github.com/ssanthosh2k3/eks-task-2.git'
        NEW_TAG = ''
    }

    stages {
        stage('Checkout Docker App') {
            steps {
                checkout([
                    $class: 'GitSCM',
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
                    NEW_TAG = "build-${env.BUILD_NUMBER}"
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

        stage('Checkout Helm Chart') {
            steps {
                dir('helm-chart') {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: 'refs/heads/main']],
                        userRemoteConfigs: [[
                            url: env.HELM_REPO,
                            credentialsId: env.GIT_CREDENTIALS
                        ]],
                        extensions: [[$class: 'LocalBranch', localBranch: 'main']]
                    ])
                }
            }
        }

        stage('Update values.yaml with new image tag') {
            steps {
                dir('helm-chart/nginx-app') {
                    script {
                        def valuesFile = 'values.yaml'
                        def content = readFile(valuesFile)
                        def updated = content.replaceAll(/tag:\s*.*/, "tag: ${NEW_TAG}")
                        writeFile(file: valuesFile, text: updated)
                        echo "Updated values.yaml with tag: ${NEW_TAG}"

                        // Git config
                        sh "git config user.email 'jenkins@example.com'"
                        sh "git config user.name 'Jenkins CI'"

                        // Add and commit changes, ignore if no changes to commit
                        sh "git add ${valuesFile}"
                        sh "git commit -m 'Update image tag to ${NEW_TAG} from Jenkins pipeline' || echo 'No changes to commit'"

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
    }
}
