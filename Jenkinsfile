#!/usr/bin/env groovy

def repoPath = 'lap/avplayer'

pipeline {
  agent {
    label "docker"
  }

  environment {
    COMPOSE_FILE = "docker-compose.ci.yml"
    DOCKER_REPO = "containers.lib.berkeley.edu/${repoPath}/${env.GIT_BRANCH.toLowerCase()}"
    DOCKER_TAG = "${DOCKER_REPO}:build-${BUILD_NUMBER}"
    DOCKER_TAG_LATEST = "${DOCKER_REPO}:latest"
    REGISTRY_CREDENTIALS = "0A792AEB-FA23-48AC-A824-5FF9066E6CA9"
  }

  stages {
    stage("Build") {
      steps {
        withDockerRegistry(url: "https://${DOCKER_REPO}", credentialsId: "${REGISTRY_CREDENTIALS}") {
          sh 'docker-compose build --pull'
          sh 'docker push "${DOCKER_TAG}"'
        }
      }
    }

    stage("Test") {
      stages {
        stage("Run") {
          steps {
            sh 'docker-compose run --rm rails assets:precompile'
            sh 'docker-compose up -d'
          }
        }
        stage("Tests") {
          parallel {
            stage("RSpec") {
              steps {
                // Run the tests
                sh 'docker-compose run --rm rails cal:test:ci'
              }
            }
            stage("Rubocop") {
              steps {
                sh 'docker-compose run --rm rails cal:test:rubocop'
              }
            }
            stage("Brakeman") {
              steps {
                sh 'docker-compose run --rm rails brakeman'
              }
            }
            stage("Audit") {
              steps {
                sh 'docker-compose run --rm rails bundle:audit'
              }
            }
          }
          post {
            always {
              sh 'docker cp "$(docker-compose ps -q rails):/opt/app/tmp/reports" tmp/reports'

              junit 'tmp/reports/specs/*.xml'

              publishBrakeman 'tmp/reports/brakeman/brakeman.json'

              publishHTML([
                reportName: 'Code Coverage',
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'tmp/reports/rcov',
                reportFiles: 'index.html',
              ])

              publishHTML([
                reportName: 'Rubocop',
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'tmp/reports/rubocop',
                reportFiles: 'index.html',
              ])
            }
          }
        }
      }

      post {
        always {
          sh 'docker-compose down -v --remove-orphans || true'
        }
      }
    }

    stage("Push") {
      steps {
        withDockerRegistry(url: "https://${DOCKER_REPO}", credentialsId: "${REGISTRY_CREDENTIALS}") {
          sh 'docker tag "${DOCKER_TAG}" "${DOCKER_TAG_LATEST}"'
          sh 'docker push "${DOCKER_TAG_LATEST}"'
        }
      }
    }
  }

  options {
    ansiColor("xterm")
    timeout(time: 10, unit: "MINUTES")
  }
}
