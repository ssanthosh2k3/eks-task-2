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
                checkout([$class: 'GitSCM',
                          branches: [[name: 'refs/heads/main']],
                          userRemoteConfigs: [[
                            url: env.DOCKER_REPO,
                            credentialsId: env.GIT_CREDENTIALS
                          ]]])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
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

        stage('Checkout Helm Chart') {
            steps {
                dir('helm-chart') {
                    checkout([$class: 'GitSCM',
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
                        def updated = content.replaceAll(/tag: .*/, "tag: ${NEW_TAG}")
                        writeFile(file: valuesFile, text: updated)
                        echo "Updated ${valuesFile} with tag: ${NEW_TAG}"
                    }
                }
            }
        }
    }
}
