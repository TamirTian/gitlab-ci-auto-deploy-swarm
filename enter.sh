#!/bin/sh
set -e
cd "$(dirname "$0")"
export PRIVATE_KEY=$GITLAB_CD_SSH_PRIVATE_KEY
export SSH_REMOTE=${GITLAB_CD_SSH_USER}@${GITLAB_CD_SSH_HOST}
export NAMESPACE=$SWARM_NAMESPACE
export SERVICE_NAME=$CI_PROJECT_NAME
export WORKDIR=/tmp/auto-deploay-swarm/$SERVICE_NAME
export ENV_FILE=$WORKDIR/${NAMESPACE}-${SERVICE_NAME}.env
export STATCK_FILE=$WORKDIR/${SERVICE_NAME}-template.yml

if [[ -z "$CI_COMMIT_TAG" ]]; then
  export IMAGE=${CI_APPLICATION_REPOSITORY:-$CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG}:${CI_APPLICATION_TAG:-$CI_COMMIT_SHA}
else
  export IMAGE=${CI_APPLICATION_REPOSITORY:-$CI_REGISTRY_IMAGE}:${CI_APPLICATION_TAG:-$CI_COMMIT_TAG}
fi

apk add --no-cache openssh-client
eval $(ssh-agent -s)
echo "$PRIVATE_KEY" | tr -d '\r' | ssh-add -
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

if [ $CI_DEBUG_TRACE == 'true' ]; then
  echo image $IMAGE
  sh -x /deploy/create-template-with-env.sh
  sh -x /deploy/upgrade-service.sh
  sh -x /deploy/check-service.sh
else
  /deploy/create-template-with-env.sh
  /deploy/upgrade-service.sh
  /deploy/check-service.sh
fi
