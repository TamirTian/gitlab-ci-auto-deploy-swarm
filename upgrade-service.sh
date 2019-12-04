#!/bin/sh
set -e
ssh $SSH_REMOTE 'bash -s' <<EOF
  chmod 600 $ENV_FILE
  IMAGE=$IMAGE ENV_FILE=$ENV_FILE REPLICAS=$REPLICAS SERVICE_NAME=$SERVICE_NAME EXPOSE_PORT=$EXPOSE_PORT docker stack deploy --with-registry-auth --compose-file=$STATCK_FILE ${NAMESPACE}
EOF
