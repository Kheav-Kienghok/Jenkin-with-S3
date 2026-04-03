pipeline {
    agent any

    stages {
        stage('Test AWS Access') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
                    sh '''
                        set -e
                        export AWS_DEFAULT_REGION=us-east-1
                        aws sts get-caller-identity
                    '''
                }
            }
        }
    }
}
