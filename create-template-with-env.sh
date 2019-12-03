#!/bin/sh
set -e
ssh $SSH_REMOTE "mkdir -p $WORKDIR"
ssh $SSH_REMOTE "cat > $STATCK_FILE" << EOF
    version: '3.7'
    services:
      $SERVICE_NAME:
        image: "\${IMAGE}"
        env_file:
          - "\${ENV_FILE}"
        healthcheck:
          test: ["CMD", "curl", "-f", "http://127.0.0.1:5000"]
          interval: 60s
          timeout: 15s
          retries: 3
          start_period: 5s
        deploy:
          update_config:
            parallelism: 1
            delay: 1s
            failure_action: rollback
          replicas: 2
          restart_policy:
            condition: on-failure
            delay: 5s
            max_attempts: 5
            window: 120s
EOF
set | grep ^SWARM_ | sed -e "s/^SWARM_//" | ssh $SSH_REMOTE "cat > $ENV_FILE"