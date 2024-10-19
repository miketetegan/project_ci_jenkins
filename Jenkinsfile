//Define on which agent to run the jobs 
pipeline {
    agent any

//Define the tools you want to use in the pipeline
    tools {
        maven 'maven'
    }

//Define the parameters at the begining of the pipeline
    parameters {
        choice choices: ['Baseline', 'APIS', 'Full'],
            description: 'Type of scan that is going to perform inside the container',
            name: 'SCAN_TYPE'
            
        string defaultValue: 'http:\\/\\/192.168.100.2:8888\\/simple-web-app\\/users',
            description: 'Target URL to scan',
            name: 'TARGET'
            
        booleanParam defaultValue: true,
            description: 'Parameter to know if you want to generate a report.',
            name: 'GENERATE_REPORT'

        //choice(name: 'ERROR_HANDLING', 
          //     choices: ['Continue', 'Abort'], 
            //   description: 'Choose how to handle errors in the pipeline')
    }
             
    environment {
        SCANNER_HOME = tool 'sonar_scanner'
    }
    
    stages {
        
        stage("Static Code Analysis (SAST)") {
            steps {
                echo "Performing Static Code Analysis"
                dir('app') {
                    sh 'mvn clean compile'
                    sh 'mvn clean package'
                }
                withSonarQubeEnv(installationName: 'sonar_server') { 
                    sh "${SCANNER_HOME}/bin/sonar-scanner \
                    -D sonar.projectName=java-app \
                    -D sonar.projectKey=java-app \
                    -D sonar.projectBaseDir=./app \
                    -D sonar.java.binaries=target/classes \
                    -D sonar.java.libraries=target/dependency "
                    //-D sonar.exclusions=**
                }
            }
        }
   
        stage("Code Quality Gate Check") {
            steps {
                script {
                  try {
                    sleep (15)
                    def qualityGate = waitForQualityGate()
                    if (qualityGate.status != 'OK') {
                        error "Quality gate failed: ${qualityGate.status}"
                      }
                    } catch (Exception e) {
                        echo "Code Quality Gate Failed: ${e.message}"
                        def userInput = input message: 'Code Quality Gate Failed. Would you like to continue the build ?',
                                             parameters: [choice(name: 'CONTINUE_OR_ABORT', 
                                                                 choices: ['Continue', 'Abort'], 
                                                                 description: 'Continue or Abort')]
                        if (userInput == 'Abort') {
                            error("Pipeline aborted by user.")
                        }
                    }
                }
            }
        }
        
        stage("Dependencies Scan (SCA)") {
             steps{
                echo "Dependencies Scan"
                dependencyCheck additionalArguments: '--nvdApiKey 839d5d5a-48a2-4b4d-94cb-a09938adad9e --scan app/ ', odcInstallation: 'dependency_check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage("Build app artifact") {
            steps {
                echo "Build Artifact"
                dir('app') {
                    sh 'mvn clean package'
                }
            }
        }
        
        stage("Dockerfile Code Analysis") {
            steps {
                echo "Dockerfile scan"
                withSonarQubeEnv(installationName: 'sonar_server') { 
                    sh "${SCANNER_HOME}/bin/sonar-scanner \
                    -D sonar.projectName=dockerfile \
                    -D sonar.projectKey=dockerfile \
                    -D sonar.projectBaseDir=. \
                    -D sonar.sources=. \
                    -D sonar.inclusions=Dockerfile"
                    //-D sonar.exclusions=**/*.java"
                }
            }
        }
        
        stage("Dockerfile Quality Gate Check") {
            steps {
                script {
                  try {
                    sleep (15)
                    def qualityGate = waitForQualityGate()
                    if (qualityGate.status != 'OK') {
                        error "Quality gate failed: ${qualityGate.status}"
                        }
                    } catch (Exception e) {
                        echo "Dockerfile Quality Gate Failed: ${e.message}"
                        def userInput = input message: 'Dockerfile QUality Gate Failed. Would you like to continue the build ?',
                                             parameters: [choice(name: 'CONTINUE_OR_ABORT', 
                                                                 choices: ['Continue', 'Abort'], 
                                                                 description: 'Continue or Abort')]
                        if (userInput == 'Abort') {
                            error("Pipeline aborted by user.")   
                        }  
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Build image"
                script {
                    def imageName = "mike004/java"
                    def imageTag = "latest"
                    // Build the Docker image using Dockerfile in the current directory
                    //docker.build("${imageName}:${imageTag}")
                    sh "docker build -t ${imageName}:${imageTag} ."
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                echo "Scanning Image for vulnerabilities"
                 //sh "trivy fs scan ."
                 //sh "trivy image --exit-code 0 java:latest"
                script {
                  try {
                    def trivyScan = sh(script: 'trivy image --exit-code 1 java:latest', returnStatus: true)
                    if (trivyScan == 0) {
                        echo "No vulnerabilities found."
                    } else if (trivyScan == 1) {
                        error "Vulnerabilities found, stopping the build."
                    } else if (trivyScan == 5) {
                        error "Trivy scan encountered an error."
                    }
                  } catch (Exception e) {
                        echo "Vulnerabilities found in image: ${e.message}"
                        def userInput = input message: 'Vulnerabilities found!. Would you like to continue the build ?',
                                             parameters: [choice(name: 'CONTINUE_OR_ABORT', 
                                                                 choices: ['Continue', 'Abort'], 
                                                                 description: 'Continue or Abort')]
                        if (userInput == 'Abort') {
                            error("Pipeline aborted by user.")
                        }
                      }
                }
            }
        }
        
        stage('App Integration Tests') {
            steps {
                echo "Running the app integration test"
                sh "docker compose up -d"
                // script {
                //def status_code = sh(script: "curl -o /dev/null -s -w '%{http_code}\n' http://192.168.100.2:8888/simple-web-app/users", returnStatus: true)
                    // def status_code = sh(script: '''curl -o /dev/null -s -w "%{http_code}\\n" http://192.168.100.2:8888/simple-web-app/users''', returnStdout: true).trim()
                    // if (status_code == 200) {
                       // echo "App is running correctly !"
                    // } else if (status_code != 200) {
                       // error "App is not running !"
                    // }
                // }
            }
        }
        
        stage('Scanning target on owasp container') {
            steps {
                script {
                    scan_type = "${params.SCAN_TYPE}"
                    echo "----> scan_type: $scan_type"
                    target = "${params.TARGET}"
                    if (scan_type == 'Baseline') {
                        sh """
                             docker exec owasp \
                             zap-baseline.py \
                             -t $target \
                             -r report.html \
                             -I
                         """
                    } else if (scan_type == 'APIS') {
                        sh """
                             docker exec owasp \
                             zap-api-scan.py \
                             -t $target \
                             -r report.html \
                             -I
                         """
                    } else if (scan_type == 'Full') {
                        sh """
                             docker exec owasp \
                             zap-full-scan.py \
                             -t $target \
                             -r report.html \
                             -I
                         """
                    } else {
                        echo "Something went wrong..."
                    }
                    sh '''
                    docker cp owasp:/zap/wrk/report.html .
                    '''
                    //sh '''
                    //docker cp report.html jenkins-blueocean:/var/jenkins_home/workspace/java_app/report.html
                    //'''
                    }
                }
            }
        
        stage('Release Image to registry') {
            steps {
                script {
                    def imageName = "mike004/java"
                    def imageTag = "latest"
                    echo "Push Docker Image to registry"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                        sh "docker push ${imageName}:${imageTag}"
                    }
                }
            }
        }
    }
}

// post { 
// }
