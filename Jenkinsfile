pipeline {
    agent any

    environment {
        DOCKER_HOST = "unix:///home/hack/.docker/desktop/docker.sock"
        APP_IMAGE = "spring-app:0.1"
        BDD_IMAGE = "bdd-test-spring-app:0.1"
        APP_CONTAINER = "spring-app-container"
        APP_REPO = "https://github.com/sys123-data/spring-hello-demo.git"
        BDD_REPO = "https://github.com/sys123-data/spring-bdd-demo.git"
    }

    stages {
        stage('Clone & Build Application') {
            steps {
                dir('spring-hello-demo') {
                    git branch: 'main', url: "${APP_REPO}"
                    script {

                        sh "docker build -t ${APP_IMAGE} ."
                    }
                }
            }
        }

        stage('Run Application') {
            steps {
                script {
                     sh "docker run -d --name ${APP_CONTAINER} -p 8083:8080 ${APP_IMAGE}"
                }
            }
        }

        stage('Clone & Build BDD Tests') {
            steps {
                dir('spring-bdd-demo') {
                    git branch: 'main', url: "${BDD_REPO}"
                    script {
                        sh "docker build -t ${BDD_IMAGE} ."
                    }
                }
            }
        }

        stage('Run BDD Tests') {
            steps {
                script {
                    sh "docker run --rm ${BDD_IMAGE}"
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up..."
            sh "docker stop ${APP_CONTAINER} || true"
            sh "docker rm ${APP_CONTAINER} || true"
        }
        success {
            echo "Application built and BDD tests executed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}