properties([disableConcurrentBuilds(), buildDiscarder(logRotator(artifactDaysToKeepStr: '5', artifactNumToKeepStr: '5', daysToKeepStr: '5', numToKeepStr: '5'))])

@Library('pipeline-library')
import dk.stiil.pipeline.Constants

podTemplate(yaml: '''
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:debug
        command:
        - sleep
        args: 
        - 99d
        volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
      restartPolicy: Never
      volumes:
      - name: kaniko-secret
        secret:
          secretName: dockerhub-dockercred
          items:
          - key: .dockerconfigjson
            path: config.json
''') {
  node(POD_LABEL) {
    TreeMap scmData
    String gitCommitMessage
    stage('checkout SCM') {  
      scmData = checkout scm
      gitCommitMessage = sh(returnStdout: true, script: "git log --format=%B -n 1 ${scmData.GIT_COMMIT}").trim()
      arch = sh(returnStdout: true, script: '''
        case $(uname -m)  in
          armv5*) echo "armv5";;
          armv6*) echo "armv6";;
          armv7*) echo "arm";;
          aarch64) echo "arm64";;
          x86) echo "386";;
          x86_64) echo "amd64";;
          i686) echo "386";;
          i386) echo "386";;
        esac''').trim()
      gitMap = scmGetOrgRepo scmData.GIT_URL
      githubWebhookManager gitMap: gitMap, webhookTokenId: 'jenkins-webhook-repo-cleanup'
      // Some comment
    }
    if ( !gitCommitMessage.startsWith("renovate/") || ! gitCommitMessage.startsWith("WIP") ) {
      stage('Build Docker Image') {
        container('kaniko') {
          def properties = readProperties file: 'package.env'
          withEnv(["GIT_COMMIT=${scmData.GIT_COMMIT}", "PACKAGE_NAME=${properties.PACKAGE_NAME}", "PACKAGE_DESTINATION=${properties.PACKAGE_DESTINATION}", "PACKAGE_CONTAINER_SOURCE=${properties.PACKAGE_CONTAINER_SOURCE}", "GIT_BRANCH=${BRANCH_NAME}", "ARCH=${arch}"]) {
            if (isMainBranch()){
              sh '''
                /kaniko/executor --force --context `pwd` --log-format text --destination $PACKAGE_DESTINATION/$PACKAGE_NAME:$BRANCH_NAME-$ARCH --destination $PACKAGE_DESTINATION/$PACKAGE_NAME:latest --label org.opencontainers.image.description="Build based on $PACKAGE_CONTAINER_SOURCE/commit/$GIT_COMMIT" --label org.opencontainers.image.revision=$GIT_COMMIT --label org.opencontainers.image.version=$GIT_BRANCH
              '''
            } else {
              sh '''
                /kaniko/executor --force --context `pwd` --log-format text --destination $PACKAGE_DESTINATION/$PACKAGE_NAME:$BRANCH_NAME-$ARCH --label org.opencontainers.image.description="Build based on $PACKAGE_CONTAINER_SOURCE/commit/$GIT_COMMIT" --label org.opencontainers.image.revision=$GIT_COMMIT --label org.opencontainers.image.version=$GIT_BRANCH
              '''
            }
          }
        }
      }
    }
  }
}