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

    stage('Core') {
      steps {
        sh 'make build-core'
        sh 'make publish-core'
      }
    }

  }
}