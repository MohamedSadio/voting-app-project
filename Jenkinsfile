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
          docker --version || { echo "❌ Docker introuvable"; exit 1; }
          docker compose version || { echo "❌ Docker Compose introuvable"; exit 1; }
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
          echo "=== Nettoyage de l'environnement Docker ==="
          
          # Arrêter et supprimer les conteneurs existants
          docker compose down --remove-orphans --volumes || true
          
          # Supprimer les réseaux orphelins
          docker network ls -q --filter "name=voting" | xargs -r docker network rm || true
          docker network ls -q --filter "name=backend" | xargs -r docker network rm || true
          
          # Nettoyer les volumes orphelins
          docker volume prune -f || true
          
          echo "=== Nettoyage terminé ==="
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
          echo "=== Démarrage de l'application ==="
          docker compose up -d
          
          echo "=== Attente du démarrage initial (15s) ==="
          sleep 15
        '''
      }
    }
    
    stage('Vérification des services') {
      steps {
        sh '''
          echo "=== État des services ==="
          docker compose ps
          
          echo "=== Attente supplémentaire pour stabilisation (45s) ==="
          sleep 45
          
          echo "=== État final des services ==="
          docker compose ps
          
          echo "=== Vérification des logs récents ==="
          docker compose logs --tail=5 db || echo "Logs DB non disponibles"
          docker compose logs --tail=5 redis || echo "Logs Redis non disponibles"
          docker compose logs --tail=5 vote || echo "Logs Vote non disponibles"
          docker compose logs --tail=5 result || echo "Logs Result non disponibles"
        '''
      }
    }
    
    stage('Tests de connectivité') {
      steps {
        sh '''
          echo "=== Test de connectivité des services ==="
          
          # Vérifier que les conteneurs sont en cours d'exécution
          RUNNING_CONTAINERS=$(docker compose ps --services --filter "status=running" | wc -l)
          echo "Nombre de conteneurs en cours d'exécution: $RUNNING_CONTAINERS"
          
          if [ "$RUNNING_CONTAINERS" -lt 3 ]; then
            echo "❌ Pas assez de conteneurs en cours d'exécution"
            docker compose ps
            exit 1
          fi
          
          # Test Vote App avec retry
          echo "Test Vote App..."
          for i in {1..5}; do
            if curl -f -s -m 10 http://localhost:${VOTE_PORT} > /dev/null; then
              echo "✅ Vote App (port ${VOTE_PORT}) - OK"
              break
            else
              echo "⏳ Tentative $i/5 pour Vote App..."
              sleep 10
            fi
            if [ $i -eq 5 ]; then
              echo "❌ Vote App (port ${VOTE_PORT}) - KO après 5 tentatives"
            fi
          done
          
          # Test Result App avec retry
          echo "Test Result App..."
          for i in {1..5}; do
            if curl -f -s -m 10 http://localhost:${RESULT_PORT} > /dev/null; then
              echo "✅ Result App (port ${RESULT_PORT}) - OK"
              break
            else
              echo "⏳ Tentative $i/5 pour Result App..."
              sleep 10
            fi
            if [ $i -eq 5 ]; then
              echo "❌ Result App (port ${RESULT_PORT}) - KO après 5 tentatives"
            fi
          done
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
        
        echo "=== Logs finaux en cas de problème ==="
        docker compose logs --tail=10 || true
      '''
    }
    success {
      echo "✅ Pipeline réussi! Services accessibles sur:"
      echo "   - Vote: http://localhost:${VOTE_PORT}"
      echo "   - Results: http://localhost:${RESULT_PORT}"
      echo "   - Jenkins: http://localhost:8080"
    }
    failure {
      sh '''
        echo "❌ Pipeline échoué - Diagnostic complet:"
        echo "=== Logs détaillés des services ==="
        docker compose logs --tail=100 || true
        
        echo "=== État des conteneurs ==="
        docker compose ps
        
        echo "=== Réseaux Docker ==="
        docker network ls
        
        echo "=== Volumes Docker ==="
        docker volume ls
      '''
    }
  }
}