pipeline {
    agent any

    parameters {
        text(
            name: 'TFVARS',
            defaultValue: '''aws_region  = "us-east-1"
bucket_name = "my-unique-static-site-bucket-12345"
environment = "dev"''',
            description: 'Terraform variables'
        )
    }

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
                        string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh '''
                            #!/bin/bash
                            set -euo pipefail
                            export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"
        
                            cat > dev.tfvars <<EOF
        ${TFVARS}
        EOF
        
                            terraform init
                            terraform validate
                            terraform plan -var-file="dev.tfvars" -out=tfplan
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Read Terraform Outputs') {
            steps {
                dir("${TF_DIR}") {
                    withCredentials([
                        string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        script {
                            env.S3_BUCKET = sh(
                                script: '''
                                    set -euo pipefail
                                    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"
                                    terraform output -raw bucket_name
                                ''',
                                returnStdout: true
                            ).trim()

                            env.WEBSITE_URL = sh(
                                script: '''
                                    set -euo pipefail
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
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
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

        always {
            dir("${TF_DIR}") {
                sh '''
                    rm -f dev.tfvars tfplan || true
                '''
            }
        }
    }
}
