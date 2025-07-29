pipeline {
  agent any

  environment {
    VOTE_PORT = '5000'
    RESULT_PORT = '5001'
    DOCKER_BUILDKIT = '1'
  }

  stages {
    stage('Check Tools') {
      steps {
        sh '''
          echo "=== Vérification Docker & Docker Compose ==="
          docker --version || { echo " Docker introuvable"; exit 1; }
          docker compose version || { echo " Docker Compose introuvable"; exit 1; }
        '''
      }
    }

    stage('Cloner le dépôt') {
      steps {
        git branch: 'main', url: 'https://github.com/MohamedSadio/voting-app.git'
      }
    }

    stage('Build des images Docker') {
      steps {
        sh 'docker compose build --pull'
      }
    }

    stage('Lancer l\'application') {
      steps {
        sh 'docker compose up -d'
      }
    }

    stage('Vérification des services') {
      steps {
        sh '''
          echo "=== État initial des services ==="
          docker compose ps
          
          echo "=== Attente du démarrage des services (30s) ==="
          sleep 30
          
          echo "=== État final des services ==="
          docker compose ps
          
          echo "=== Vérification des logs d'erreur ==="
          docker compose logs --tail=10
        '''
      }
    }

    stage('Tests de connectivité') {
      steps {
        sh '''
          echo "=== Test de connectivité des services ==="
          
          # Test Vote App
          if curl -f -s http://localhost:${VOTE_PORT} > /dev/null; then
            echo " Vote App (port ${VOTE_PORT}) - OK"
          else
            echo " Vote App (port ${VOTE_PORT}) - KO"
          fi
          
          # Test Result App
          if curl -f -s http://localhost:${RESULT_PORT} > /dev/null; then
            echo " Result App (port ${RESULT_PORT}) - OK"
          else
            echo " Result App (port ${RESULT_PORT}) - KO"
          fi
        '''
      }
    }
  }

  post {
    always {
      sh '''
        echo "=== État final de tous les conteneurs ==="
        docker compose ps
        echo "=== Résumé des services ==="
        docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
      '''
    }
    success {
      echo " Pipeline réussi! Services accessibles sur:"
      echo "   - Vote: http://localhost:${VOTE_PORT}"
      echo "   - Results: http://localhost:${RESULT_PORT}"
      echo "   - Jenkins: http://localhost:8080"
    }
    failure {
      sh '''
        echo " Pipeline échoué - Logs de débogage:"
        echo "=== Logs des services ==="
        docker compose logs --tail=50
        echo "=== État des conteneurs ==="
        docker compose ps
      '''
    }
  }
}