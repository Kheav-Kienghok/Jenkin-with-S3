pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_DIR             = 'terraform'
        WEBSITE_DIR        = 'website'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check Tools') {
            steps {
                sh '''
                    set -e
                    git --version
                    terraform version
                    aws --version
                '''
            }
        }

        stage('Terraform Init Plan Apply') {
            steps {
                dir("${TF_DIR}") {
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: 'aws-jenkins-creds'
                        ],
                        file(credentialsId: 'dev-tfvars-file', variable: 'TFVARS_FILE')
                    ]) {
                        sh '''
                            set -euo pipefail
                            export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"

                            terraform init
                            terraform validate
                            terraform plan -var-file="$TFVARS_FILE" -out=tfplan
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Read Terraform Outputs') {
            steps {
                dir("${TF_DIR}") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins-creds'
                    ]]) {
                        script {
                            env.S3_BUCKET = sh(
                                script: '''
                                    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"
                                    terraform output -raw bucket_name
                                ''',
                                returnStdout: true
                            ).trim()

                            env.WEBSITE_URL = sh(
                                script: '''
                                    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"
                                    terraform output -raw website_url
                                ''',
                                returnStdout: true
                            ).trim()
                        }
                    }
                }
            }
        }

        stage('Upload Website Files') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
                    sh '''
                        set -euo pipefail
                        export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"
                        aws s3 sync "${WEBSITE_DIR}/" "s3://${S3_BUCKET}" --delete
                    '''
                }
            }
        }

        stage('Show Website URL') {
            steps {
                echo "Website URL: http://${env.WEBSITE_URL}"
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully.'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
