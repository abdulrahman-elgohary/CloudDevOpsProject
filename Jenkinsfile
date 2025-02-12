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
        stage('Checkout Code') {
            steps {
                script {
                    gitCheckout(REPO_URL,BRANCH)
                }
            }
        }


        stage('Check Commit Message') {
            steps {
                script {
                    // Fetch the latest commit message
                    def commitMessage = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()

                    // Skip the build if the commit message contains "[ci skip"
                    if (commitMessage.contains("[ci skip]")) {
                        echo "Skipping build due to commit message: ${commitMessage}"
                        currentBuild.result = 'ABORTED'
                        // **Force stop the pipeline**
                        currentBuild.rawBuild.stop()

                        return
                    }
                }
            }
        }
        
        

        stage('Unit Test') {
            steps {
                script {
                    // Add delay to prevent immediate retrigger
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
