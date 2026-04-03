pipeline {
    agent any

    stages {
        stage('Test AWS Credential Binding') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-jenkins-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                        set -e
                        test -n "$AWS_ACCESS_KEY_ID"
                        test -n "$AWS_SECRET_ACCESS_KEY"
                        echo "AWS credentials are visible to this job"
                    '''
                }
            }
        }

        stage('Test AWS Access') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-jenkins-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
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
