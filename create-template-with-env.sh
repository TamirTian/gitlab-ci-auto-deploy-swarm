#!/bin/sh
set -e
if [[ -n "$EXPOSE_PORT" ]]; then
export EXPOSE_PORT_STR="$(cat << EOF
    ports:
      ${EXPOSE_PORT}:${SWARM_PORT:-5000}
EOF
)"
fi
ssh $SSH_REMOTE "mkdir -p $WORKDIR"
if [[ -n "$STATCK_CUSTOMIZE_FILE" ]]; then
cat $STATCK_CUSTOMIZE_FILE | ssh $SSH_REMOTE "cat > $STATCK_FILE"
else
ssh $SSH_REMOTE "cat | sed -e '/^[[:space:]]*$/d' > $STATCK_FILE" << EOF
version: '3.7'
services:
  ${SERVICE_NAME}:
    image: "\${IMAGE}"
    env_file:
      - "\${ENV_FILE}"
$EXPOSE_PORT_STR
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:5000/healthcheck"]
      interval: 5s
      timeout: 10s
      retries: 3
      start_period: 15s
    deploy:
      update_config:
        parallelism: 1
        delay: 1s
        failure_action: rollback
      replicas: \${REPLICAS}
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 5
        window: 120s
EOF
fi
set | grep ^SWARM_ | sed -e "s/^SWARM_//" -e 's/='\''/=/' -e 's/'\''$//' | ssh $SSH_REMOTE "cat > $ENV_FILE"
