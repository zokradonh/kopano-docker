pipeline {
  agent {
    node {
      label 'docker'
    }

  }
  stages {
    stage('Test') {
      steps {
        sh 'printenv | sort'
      }
    }

    stage('Base') {
      steps {
        sh 'make build-base'
        sh 'make publish-base'
      }
    }

    stage('SSL') {
      steps {
        sh 'make build-ssl'
        sh 'make publish-ssl'
      }
    }
		
    stage('Core') {
      steps {
        sh 'make build-core'
        sh 'make publish-core'
      }
    }

    stage('Scheduler') {
      steps {
        sh 'make build-scheduler'
        sh 'make publish-scheduler'
      }
    }

    stage('WepApp') {
      steps {
        sh 'make build-webapp'
        sh 'make publish-webapp'
      }
    }

    stage('Web') {
      steps {
        sh 'make build-web'
        sh 'make publish-web'
      }
    }

    stage('Z-Push') {
      steps {
        sh 'make build-zpush'
        sh 'make publish-zpush'
      }
    }

  }
}
