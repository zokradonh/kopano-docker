pipeline {
  agent {
    node {
      label 'docker'
    }

  }
  stages {
    stage('Setup') {
      steps {
        sh 'printenv | sort'
        sh 'git config --global user.email "ecw@kleinhain.de"'
        sh 'git config --global user.name "Enrico Walther"'
      }
    }

    stage('Build') {
      steps {
        sh 'make build-base'
        sh 'make build-ssl'
        sh 'make build-core'
        sh 'make build-scheduler'
        sh 'make build-webapp'
        sh 'make build-web'
        sh 'make build-zpush'
      }
    }

    stage('Publish') {
      steps {
		
        sh 'make publish-base'
        sh 'make publish-ssl'
        sh 'make publish-core'
        sh 'make publish-scheduler'
        sh 'make publish-webapp'
        sh 'make publish-web'
        sh 'make publish-zpush'
      }
    }
  }
}
