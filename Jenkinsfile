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
          docker --version || { echo " Docker introuvable"; exit 1; }
          docker compose version || { echo " Docker Compose introuvable"; exit 1; }
        '''
      }
    }
    
    stage('Cloner le dépôt') {
      steps {
        git branch: 'main', url: 'https://github.com/MohamedSadio/voting-app-project.git'
      }
    }
    
    stage('Nettoyage environnement') {
      steps {
        sh '''
          docker compose down --remove-orphans --volumes || true
          docker network ls -q --filter "name=voting" | xargs -r docker network rm || true
          docker network ls -q --filter "name=backend" | xargs -r docker network rm || true
          docker volume prune -f || true
        '''
      }
    }
    
    stage('Build des images Docker') {
      steps {
        sh 'docker compose build --pull'
      }
    }
    
    stage('Lancer l\'application') {
      steps {
        sh '''
          docker compose up -d
          sleep 30
        '''
      }
    }
    
    stage('Tests de connectivité') {
      steps {
        sh '''
          # Vérifier les conteneurs actifs
          RUNNING_CONTAINERS=$(docker compose ps --services --filter "status=running" | wc -l)
          if [ "$RUNNING_CONTAINERS" -lt 3 ]; then
            echo " Pas assez de conteneurs actifs"
            exit 1
          fi
          
          # Test Vote App
          if curl -f -s -m 10 http://localhost:${VOTE_PORT} > /dev/null; then
            echo " Vote App - OK"
          else
            echo " Vote App - KO"
          fi
          
          # Test Result App  
          if curl -f -s -m 10 http://localhost:${RESULT_PORT} > /dev/null; then
            echo " Result App - OK"
          else
            echo " Result App - KO"
          fi
        '''
      }
    }
  }
  
  post {
    success {
      echo " Pipeline réussi! Services accessibles sur:"
      echo "   - Vote: http://localhost:${VOTE_PORT}"
      echo "   - Results: http://localhost:${RESULT_PORT}"
    }
    failure {
      sh '''
        echo " Pipeline échoué:"
        docker compose ps
        docker compose logs --tail=20
      '''
    }
  }
}