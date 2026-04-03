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

        // Wrap Terraform stages with AWS plugin credentials
        stage('Terraform Init & Plan & Apply') {
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${AWS_DEFAULT_REGION}") {
                    dir("${TF_DIR}") {
                        withCredentials([string(credentialsId: 'dev-tfvars', variable: 'TFVARS_CONTENT')]) {
                            sh '''
                            # Convert single-line secret into proper multi-line .tfvars
                            echo "$TFVARS_CONTENT" | sed 's/\\s\\+bucket_name/\\nbucket_name/' | sed 's/\\s\\+environment/\\nenvironment/' > temp.tfvars

                            terraform init
                            terraform validate
                            terraform plan -var-file=temp.tfvars -out=tfplan
                            terraform apply -var-file=temp.tfvars -auto-approve tfplan
                            '''
                        }
                    }
                }
            }
        }

        stage('Get Bucket Name') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        env.S3_BUCKET = sh(
                            script: 'terraform output -raw bucket_name',
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('Upload Website Files') {
            steps {
                // Wrap AWS CLI with the same AWS credentials
                withAWS(credentials: 'aws-access-key-id', region: "${AWS_DEFAULT_REGION}") {
                    sh 'aws s3 sync ${WEBSITE_DIR}/ s3://${S3_BUCKET} --delete'
                }
            }
        }

        stage('Show Website URL') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        env.WEBSITE_URL = sh(
                            script: 'terraform output -raw website_url',
                            returnStdout: true
                        ).trim()
                        echo "Website URL: http://${WEBSITE_URL}"
                    }
                }
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
