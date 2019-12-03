#!/bin/sh
set -e
TIMES=100
ssh $SSH_REMOTE sh <<EOF
#!/bin/sh
for i in \`seq 1 $TIMES\`;
do
sleep 3
  echo "Checking the service \$i/$TIMES"
  REPLICA_IMAGE=\$(docker service inspect ${NAMESPACE}_${SERVICE_NAME} --format "{{.Spec.TaskTemplate.ContainerSpec.Image}}" | awk \-F '[@=]' '{print \$1}')
  REPLICAS=\$(docker service inspect ${NAMESPACE}_${SERVICE_NAME} --format "{{.Spec.Mode.Replicated.Replicas}}")
  RUNNING_TOTAL=\$(docker service ps ${NAMESPACE}_${SERVICE_NAME} --format '{{.CurrentState}} {{.Image}}' | grep $IMAGE | grep Running | wc -l)

  if [ \$REPLICA_IMAGE != $IMAGE ]
  then
    echo 'Invalid Docker Image. The service maybe rollbacked'
    exit 1
    break
  fi

  if [ \$REPLICAS == \$RUNNING_TOTAL ]
  then
    echo 'Upgraded the image successful'
    break
  elif [ \$i == $TIMES ]
  then
   echo 'Upgrade the image failed'
   exit 1
  fi
done
EOF
