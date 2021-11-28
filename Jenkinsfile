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

  }
}