@Library('jenkins-shared-library') _
pipeline {
    agent {
        label 'my_slave'
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
        REPO_SSH = 'git@github.com:abdulrahman-elgohary/CloudDevOpsProject.git'
        REPO_NAME = 'CloudDevOpsProject'
        BRANCH = 'main'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Check Commit Message') {
            steps {
                script {
                    // Get the commit message from the environment variable
                    def commitMessage = env.GIT_COMMIT_MESSAGE
                    if (commitMessage.contains("[skip ci]")) {
                        // Skip the build if the commit message contains "[skip ci]"
                        echo "Skipping build due to commit message: ${commitMessage}"
                        currentBuild.result = 'ABORTED'
                        return
                    }
                }
            }
        }
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
                        gitRepo: REPO_SSH,
                        githubEmail: GITHUB_EMAIL,
                        githubUsername: GITHUB_USERNAME,
                        branch: BRANCH
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
