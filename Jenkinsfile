pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_DIR             = 'terraform'
        WEBSITE_DIR        = 'website'
        AWS_CREDS_ID       = 'aws-jenkins-creds'
        TFVARS_FILE_ID     = 'dev-tfvars-file'
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
                    which git || true
                    git --version || true
                    which terraform || true
                    terraform version || true
                    which aws || true
                    aws --version || true
                '''
            }
        }

        stage('Terraform Init Plan Apply') {
            steps {
                withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_DEFAULT_REGION}") {
                    dir("${TF_DIR}") {
                        withCredentials([file(credentialsId: "${TFVARS_FILE_ID}", variable: 'TFVARS_FILE')]) {
                            sh '''
                                set -euo pipefail
                                terraform init
                                terraform validate
                                terraform plan -var-file="$TFVARS_FILE" -out=tfplan
                                terraform apply -auto-approve tfplan
                            '''
                        }
                    }
                }
            }
        }

        stage('Read Terraform Outputs') {
            steps {
                withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_DEFAULT_REGION}") {
                    dir("${TF_DIR}") {
                        script {
                            env.S3_BUCKET = sh(
                                script: 'terraform output -raw bucket_name',
                                returnStdout: true
                            ).trim()

                            env.WEBSITE_URL = sh(
                                script: 'terraform output -raw website_url',
                                returnStdout: true
                            ).trim()
                        }
                    }
                }
            }
        }

        stage('Upload Website Files') {
            steps {
                withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                        set -euo pipefail
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
}
