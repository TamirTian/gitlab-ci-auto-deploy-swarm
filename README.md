# Auto deploy the service to swarm by ssh from Gitlab CI
Healthcheck on 5000
### Require Envs
* GITLAB_CD_SSH_HOST
* GITLAB_CD_SSH_PRIVATE_KEY
* GITLAB_CD_SSH_USER
* SWARM_NAMESPACE

### Customize Envs
SWARM_*

e.g.
* SWARM_NODE_ENV=production 
* SWARM_PORT=5000

are equal below 
* NODE_ENV=production
* PORT=5000

### .gitlab-ci.yml
```yaml
staging:
  stage: staging
  image: 94tamir/auto-deploy-swarm:0.0.1
  environment:
    name: staging
  script:
    - /deploy/enter.sh
  only:
    - master

production:
  stage: production
  image: 94tamir/auto-deploy-swarm:0.0.1
  when: manual
  environment:
    name: production
  script:
    - /deploy/enter.sh
  only:
    - master
```
