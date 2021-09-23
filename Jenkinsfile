pipeline {
    agent {
    label 'slave1'
    }

    stages {
        stage('Cloning Code from Git') {
            steps {
                git 'https://github.com/krunalbhoyar/jenkins-project.git'
            }
        }
        stage ('sonarqube analysis') {        
          steps {	    
            //sh 'echo "+++++Running Test Cases+++++"'
	    //sh 'npm test'
            sh 'echo "+++++Scanning code coverage+++++"'
            withSonarQubeEnv("sonarqube") {
             sh "${tool("sonarqube")}/bin/sonar-scanner"   
    
            }
          }
        }
        /*stage("Quality Gate"){
          steps {
            timeout(time: 5, unit: 'MINUTES') { // Just in case something goes wrong, pipeline will be killed after a timeout
            def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
            if (qg.status != 'OK') {
             error "Pipeline aborted due to quality gate failure: ${qg.status}"
            }
           }
          }
         }*/
        
        stage('Build Docker Image') {
            steps {
                echo '+++++Building the Docker image+++++'
                sh 'sudo docker build -t spring-petclinic-angular .'
                echo '+++++Docker image build successfully+++++'
                sh 'sudo docker images'
            }
        }
        stage('STOPPING THE PREVIOUS VERSION OF docker container') {
                steps {
                    echo '+++++Stopping & removing the Application+++++'
                    sh 'sudo docker rm -f $(sudo docker container ls | grep spring-petclinic-angular-app | awk '{print $1}')'
                    echo '+++++Application Stopped+++++'
                }
        }
        stage('Deploy Application') {
            steps {
                 echo '+++++Deploying the Application on slave1+++++'
                    sh 'sudo docker run -d -p 8080:8080 --name spring-petclinic-angular-app spring-petclinic-angular:latest'
                    echo '+++++Application Running Successfully+++++'
                
            }
        }
        
    }
}

