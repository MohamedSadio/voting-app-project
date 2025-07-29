# Utilise l'image officielle Jenkins LTS comme base
FROM jenkins/jenkins:lts

# Passe en root pour installer Docker CLI
USER root

# Mise Ã  jour et installation des paquets nÃ©cessaires
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Remet l'utilisateur Jenkins (pour Ã©viter d'exÃ©cuter Jenkins en root)
USER jenkins

# DÃ©finir le rÃ©pertoire de travail
WORKDIR /var/jenkins_home