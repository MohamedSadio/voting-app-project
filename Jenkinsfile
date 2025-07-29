pipeline {
    agent any

    environment {
        COMPOSE_FILE = 'docker-compose.yml'
    }

    stages {
        stage('Clone') {
            steps {
		git url: 'https://github.com/SidyGueye/voting-app.git', branch: 'main'
            }
        }

        stage('Build') {
            steps {
                sh 'docker-compose build'
            }
        }

        stage('Deploy') {
            steps {
                sh 'docker-compose up -d'
            }
        }

        stage('Vérification') {
            steps {
                echo '--- Conteneurs en cours ---'
                sh 'docker ps'
            }
        }
    }

    post {
        success {
            echo ' Déploiement réussi !'
        }
        failure {
            echo ' Le déploiement a échoué.'
        }
    }
}
