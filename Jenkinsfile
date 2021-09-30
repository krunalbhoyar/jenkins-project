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
        /*stage ('sonarqube analysis') {        
          steps {	    
            sh 'echo "+++++Running code Coverage+++++"'
	    sh 'ng test --no-watch --code-coverage'
            sh 'echo "+++++Scanning code coverage+++++"'
            withSonarQubeEnv("sonarqube") {
             sh "${tool("sonarqube")}/bin/sonar-scanner"   
    
            }
          }
        }*/
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
        stage('STOPPING THE PREVIOUS VERSION OF Docker Container') {
                steps {
                    echo '+++++Stopping & removing the Application+++++'
                    sh 'sudo docker stop spring-petclinic-angular-app | xargs docker rm'
                    //sh 'docker container ls -a -f name=spring-petclinic-angular-app -q | xargs -r docker container rm'
                    echo '+++++Application Stopped+++++'
                }
        }
        stage('Deploy Application') {
            steps {
                 echo '+++++Deploying the Application on slave1+++++'
                    sh 'sudo docker run -d -p 8081:8080 --name spring-petclinic-angular-app spring-petclinic-angular:latest'
                    echo '+++++Application Running Successfully+++++'
                
            }
        }
        
    }
}

