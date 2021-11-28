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

    stage('Build') {
      steps {
        sh 'make build-base'
      }
    }

  }
}