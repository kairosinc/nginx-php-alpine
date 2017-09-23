#!groovy

pipeline {
    agent any

    environment {
        def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        def gitUrl = sh(returnStdout: true, script: 'git config remote.origin.url').trim()
    }

    stages {
        stage('Docker Build'){
            steps {
                sh 'GIT_URL=${gitUrl} GIT_BRANCH=${BRANCH_NAME} GIT_COMMIT=${gitCommit} /usr/local/bin/kairos-build-quay.sh prod'
            }
        }

    }

    post {
        success {
            slackSend  failOnError: true,
                           channel: '#jenkins',
                             color: '#139C8A',
                           message: "BUILD SUCCESS:\n  JOB: ${env.JOB_NAME} [${env.BUILD_NUMBER}]\n  BUILD URL: ${env.BUILD_URL}"
        }

        failure {
            slackSend  failOnError: true,
                           channel: '#jenkins',
                             color: '#FF6347',
                           message: "BUILD FAILURE:\n  JOB: ${env.JOB_NAME} [${env.BUILD_NUMBER}]\n  BUILD URL: ${env.BUILD_URL}"
        }

        unstable {
            slackSend  failOnError: true,
                           channel: '#jenkins',
                             color: '#1175E3',
                           message: "BUILD UNSTABLE:\n  JOB: ${env.JOB_NAME} [${env.BUILD_NUMBER}]\n  BUILD URL: ${env.BUILD_URL}"
        }
    }

    options {
        // For example, we'd like to make sure we only keep 10 builds at a time, so
        // we don't fill up our storage!
        buildDiscarder(logRotator(numToKeepStr:'10'))

        // And we'd really like to be sure that this build doesn't hang forever, so
        // let's time it out after an hour.
        timeout(time: 60, unit: 'MINUTES')
      }
}
