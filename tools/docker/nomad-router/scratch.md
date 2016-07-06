## Upstreams file

- upstream name, app-color
- range over the service name, app-color

## Vhosts file

- reference upstream name in proxy_pass, app-color, onlf if .Tags contains $color

## Nomad file

- job name to query with nomad status: app-color
- group name, does not matter unless using $TASKGROUP
- task, matters if you have multiple containers
- service name query with consul-template in upstream file, app-color

## Consul keys for each app

app-name, for example, would be node-example, but not node-example-green.

- prod/apps/app-name/domain contains fqdn
- prod/apps/app-name/deploy/current contains current color
- prod/service/app-name-color contains app-name

### Run this when creating a new service

```
#!/bin/bash
ENV_ID=prod
DOMAIN=node-example.example.com
APP_NAME=node-example

curl -XPUT consul-server:8500/v1/kv/prod/apps/${APP_NAME}/domain -d ${DOMAIN}
curl -XPUT consul-server:8500/v1/kv/prod/services/${APP_NAME}-green -d ${APP_NAME}
curl -XPUT consul-server:8500/v1/kv/prod/services/${APP_NAME}-blue -d ${APP_NAME}
```

### Deploy Script
```
#!/bin/bash
APP_NAME=node-example
COLOR=green
curl -XPUT consul-server:8500/v1/kv/prod/apps/${APP_NAME}/deploy/current -d ${COLOR}
```
### Debug
```
# Retrieve a value and base64 decode
curl -s consul-server:8500/v1/kv/prod/apps/node-example/deploy/current | jq -r '.[].Value' | base64 -d
```
