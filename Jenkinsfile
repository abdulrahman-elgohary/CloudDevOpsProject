@Library('jenkins-shared-library') _
pipeline {
    agent {
        label 'Build-Agent'
    }
    
    environment {
        SONARQUBE_SERVER = 'SonarQube'
        DOCKER_IMAGE_NAME = 'ivolve-app'
        DOCKERHUB_USERNAME = 'gohary101'
        REGISTRY_CREDENTIALS = 'Docker-Hub'
        GITHUB_CREDENTIALS = 'GitHub'
        GITHUB_USERNAME = "abdulrahman-elgohary"
        GITHUB_EMAIL = "abdulrahmanelgohary101@gmail.com"
        KUBECONFIG = 'kubeconfig'
        REPO_URL = 'https://github.com/abdulrahman-elgohary/CloudDevOpsProject.git'
        BRANCH = 'main'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                script {
                    gitCheckout(REPO_URL,BRANCH)
                }
            }
        }

        stage('Unit Test') {
            steps {
                script {
                    unitTest()
                }
            }
        }

        stage('Build JAR') {
            steps {
                script {
                    buildJar()
                }
            }
        }

        stage('SonarQube') {
            steps {
                script {
                    sonarQubeTest([
                        sonarQubeServer: SONARQUBE_SERVER
                    ])
                }
            }
        }
        
        stage('Build Image and Push to DockerHub') {
            steps {
                script {
                    buildandPushImage([
                        docker_hub_username: DOCKERHUB_USERNAME,
                        imageName: DOCKER_IMAGE_NAME,
                        buildNumber: BUILD_NUMBER,
                        registryCredentials: REGISTRY_CREDENTIALS
                        ])
                }
            }
        }

        stage('Push To Github') {
            steps {
                script {
                    pushToGithub([
                        registryCredentials: GITHUB_CREDENTIALS,
                        githubEmail: GITHUB_EMAIL,
                        githubUsername: GITHUB_USERNAME
                        ])

                }
            }
        }

    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
