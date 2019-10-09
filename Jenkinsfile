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
                        retry(5) {
                            sh 'docker-compose up -d'
                            sh 'docker-compose run --rm rails assets:precompile'
                        }
                    }
                }
                stage("RSpec") {
                    steps {
                        // Run the tests
                        sh 'docker-compose run --rm rails cal:test:ci'
                    }
                    post {
                        always {
                            // Copy test results (if any) before exiting
                            sh 'docker cp "$(docker-compose ps -q rails):/opt/app/test/reports" test/reports'

                            // Archive test reports
                            junit 'test/reports/SPEC-*.xml'
                            publishBrakeman 'test/reports/brakeman.json'

                            // Publish code coverage reports (if any)
                            publishHTML([
                                    allowMissing: true,
                                    alwaysLinkToLastBuild: false,
                                    keepAll: true,
                                    reportDir: 'test/reports/rcov',
                                    reportFiles: 'index.html',
                                    reportName: 'Code Coverage',
                            ])
                        }
                    }
                }
                stage("Audit") {
                    steps {
                        // Run audit checks against rubygems dependencies
                        sh 'docker-compose run --rm rails bundle:audit'
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
}