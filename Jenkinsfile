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

        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    withCredentials([string(credentialsId: 'dev-tfvars', variable: 'TFVARS_CONTENT')]) {
                        // Create a temporary .tfvars file
                        sh '''
                        echo "$TFVARS_CONTENT" > temp.tfvars
                        terraform plan -var-file=temp.tfvars -out=tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    withCredentials([string(credentialsId: 'dev-tfvars', variable: 'TFVARS_CONTENT')]) {
                        sh '''
                        echo "$TFVARS_CONTENT" > temp.tfvars
                        terraform apply -var-file=temp.tfvars -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Get Bucket Name') {
            steps {
                script {
                    env.S3_BUCKET = sh(
                        script: "cd ${TF_DIR} && terraform output -raw bucket_name",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Upload Website Files') {
            steps {
                sh 'aws s3 sync ${WEBSITE_DIR}/ s3://${S3_BUCKET} --delete'
            }
        }

        stage('Show Website URL') {
            steps {
                script {
                    env.WEBSITE_URL = sh(
                        script: "cd ${TF_DIR} && terraform output -raw website_url",
                        returnStdout: true
                    ).trim()

                    echo "Website URL: http://${WEBSITE_URL}"
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
