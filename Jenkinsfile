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
      }
    }

    stage('Core') {
      steps {
        sh 'make build-core'
      }
    }

  }
}