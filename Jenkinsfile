pipeline {
    agent {
      label "jenkins-gradle"
    }
    environment {
      JENKINS_CONTAINER_TAG = 'gradle'
      ORG               = 'fairspace'
      APP_NAME          = 'keycloak-configuration'
      DOCKER_REPO       = 'docker-registry.jx.test.fairdev.app'

      DOCKER_REPO_CREDS = credentials('jenkins-x-docker-repo')

      DOCKER_TAG_PREFIX = "$DOCKER_REPO/$ORG/$APP_NAME"
    }
    stages {
      stage('Build docker image') {
        steps {
          container(JENKINS_CONTAINER_TAG) {
            sh "docker build ."
          }
        }
      }
      stage('Release docker image') {
        when {
          branch 'master'
        }
        steps {
          container(JENKINS_CONTAINER_TAG) {
            sh "echo \$(jx-release-version) > VERSION"
            sh "export VERSION=`cat VERSION` && docker build . --tag \$DOCKER_TAG_PREFIX:\$VERSION && docker push \$DOCKER_TAG_PREFIX:\$VERSION"
          }
        }
      }
    }
}
