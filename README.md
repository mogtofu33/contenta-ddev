# ContentaCMS - ContentaJs with Docker managed by ddev

[![Build Status](https://travis-ci.com/Mogtofu33/contenta-ddev.svg?branch=master)](https://travis-ci.com/Mogtofu33/contenta-ddev)

This project is a basic Drupal [ContentaCMS](https://www.contentacms.org/) / [ContentaJS](https://github.com/contentacms/contentajs#readme) environment stack with [ddev](https://github.com/drud/ddev).

- [System Requirements](#system-requirements)
- [Features](#features)
- [Quick installation](#quick-installation)
- [Manual installation](#manual-installation)
  - [ddev Installation (Linux example)](#ddev-installation-linux-example)
  - [Grab this project as a starting point](#grab-this-project-as-a-starting-point)
  - [Download ContentaJs](#download-contentajs)
  - [Init ddev project](#init-ddev-project)
  - [Download ContentaCMS](#download-contentacms)
  - [Install ContentaCMS](#install-contentacms)
  - [Restart for ContentaJS to connect to ContentaCMS](#restart-for-contentajs-to-connect-to-contentacms)
  - [(Optionnal) Vue + Nuxt frontend](#optionnal-vue--nuxt-frontend)
- [Usage](#usage)
- [Daily Usage](#daily-usage)
- [Issues](#issues)

## System Requirements

- [Docker 18.06+](https://store.docker.com/search?type=edition&offering=community)
- [Docker Compose 1.22+](https://docs.docker.com/compose/install/)
- [ddev v1.3.0+](https://github.com/drud/ddev)

Tested on Ubuntu, see [ddev](https://ddev.readthedocs.io/en/latest/#system-requirements) for more details.

## Features

Include default ddev stack for Drupal (Nginx, Php 7.1 fpm, Mariadb, PhpMyAdmin, Mailhog) and extra services:

- [Pm2](http://pm2.keymetrics.io/docs/usage/docker-pm2-nodejs/) to run [ContentaJS](https://github.com/contentacms/contentajs)
- [Redis (WIP)](https://hub.docker.com/_/redis/), to connect with [ContentaJS](https://github.com/contentacms/contentajs)
- [Portainer](https://hub.docker.com/r/portainer/portainer) for Docker administration

## Quick installation

If you are on Ubuntu 16+/Debian, you can try to use the __install.sh__ script included
to perform an installation of ContentaCMS, ContentaJS and Contenta_vue_nuxt.

```shell
curl -fSL https://github.com/Mogtofu33/contenta-ddev/archive/master.tar.gz -o contenta-ddev.tar.gz
tar -xzf contenta-ddev.tar.gz && mv contenta-ddev-master contenta-ddev
cd contenta-ddev
chmod a+x install.sh
./install.sh
```

If everything is good go to section [Usage](#usage).

If it fail you can follow manual steps below.

## Manual installation

### ddev Installation (Linux example)

- [https://ddev.readthedocs.io/en/latest/#installation](https://ddev.readthedocs.io/en/latest/#installation)

```shell
curl -L https://raw.githubusercontent.com/drud/ddev/master/install_ddev.sh | bash
```

### Grab this project as a starting point

```shell
curl -fSL https://github.com/Mogtofu33/contenta-ddev/archive/master.tar.gz -o contenta-ddev.tar.gz
tar -xzf contenta-ddev.tar.gz && mv contenta-ddev-master contenta-ddev
cd contenta-ddev
```

### Download ContentaJs

```shell
curl -fSL https://github.com/contentacms/contentajs/archive/master.tar.gz -o contentajs.tar.gz
tar -xzf contentajs.tar.gz && mv contentajs-master contentajs
```

Edit __contentajs/package.json__ and replace __start__ with:

```json
    "start": "npm run build && PM2_HOME=/home/node/app pm2-runtime start ecosystem.config.js --name contentajs --no-auto-exit",
```

Edit __contentajs/ecosystem.config.js__ set __watch__ to _true_ for dev and add __ignore_watch__:

```json
    watch: true,
    ignore_watch: ["node_modules", "client/img", "logs", "pids", "touch", "pm2.pid", "rpc.sock", "pub.sock"],
```

Create a local config in __contentajs/config/local.yml__

```yaml
cms:
  host: http://contenta.ddev.local
got:
  applicationCache:
    activePlugin: redis
    plugins:
      redis:
        host: redis
        port: 6379
        prefix: 'contentajs::'
cors:
  origin:
    # It's OK to use '*' in local development.
    - '*'
```

### Init ddev project

Prepare contentaCMS folders and init the project

```shell
mkdir -p ./contentacms/web/sites/default
ddev config --projecttype drupal8 --projectname contenta --docroot contentacms/web \
  --additional-hostnames front-vue,front-react
```

Copy specific Contenta files from __ddev-files__ in __.ddev__ folder

```shell
cp ddev-files/*.yaml .ddev
```

_Note_: _Nodejs_ is included in the docker service and used to install ContentaJs,
if you want to install the project locally (eg: npm install), edit and switch
__command__ line in __.ddev/docker-compose.pm2.yaml__ file.
To avoid re-install on each restart you can switch the __command__ after the first
launch.

If you have composer locally you can share the cache folder by editing __.ddev/docker-compose.overrride.yaml__ file and set your cache.

```shell
ddev start
```

### Download ContentaCMS

Install with Composer within ddev

```shell
ddev exec composer create-project contentacms/contenta-jsonapi-project /tmp/contentacms \
  --stability dev --no-interaction --remove-vcs --no-progress --prefer-dist -v
ddev exec cp -r /tmp/contentacms/ /var/www/html/
ddev exec rm -rf /tmp/contentacms/
```

Create tmp folder and copy ContentaCMS config to match ddev requirements

```shell
mkdir -p contentacms/web/sites/default/files/tmp && mkdir -p contentacms/web/sites/default/files/sync
cp -r contentacms/web/profiles/contrib/contenta_jsonapi/config/sync/ contentacms/web/sites/default/files/
```

### Install ContentaCMS

```shell
# Ensure settings and permissions by running ddev config again.
ddev config --projecttype drupal8 --projectname contenta --docroot contentacms/web \
  --additional-hostnames front-vue,front-react
```

Until this [issue](https://www.drupal.org/project/jsonapi_extras/issues/3013544) is resolved, fallback to jsonapi_extras:2.10__

```shell
ddev exec composer require --prefer-dist  --working-dir=/var/www/html/contentacms drupal/jsonapi_extras:2.10
```

Install ContentaCMS

```shell
ddev exec drush si contenta_jsonapi --account-pass=admin --verbose
```

Open CORS on ContentaCMS, edit __contentacms/web/sites/default/services.yml__ and
replace __allowedOrigins__

```yml
    allowedOrigins:
      - '*'
```

### Restart for ContentaJS to connect to ContentaCMS

Before restarting, ensure ContentaJS is installed by checking if there is a file __contentajs/pm2.pid__.
If not, wait until this file is created. You can check logs with:

```shell
ddev logs -s pm2
```

_Note_: You can edit and switch __command__ line in __.ddev/docker-compose.pm2.yaml__ file.
To avoid re-install on restart.

```shell
ddev restart
```

### (Optionnal) Vue + Nuxt frontend

- [https://github.com/contentacms/contenta_vue_nuxt](https://github.com/contentacms/contenta_vue_nuxt)

```shell
curl -fSL https://github.com/contentacms/contenta_vue_nuxt/archive/master.tar.gz -o contenta_vue_nuxt.tar.gz
tar -xzf contenta_vue_nuxt.tar.gz && mv contenta_vue_nuxt-master contenta_vue_nuxt
cp ddev-files/docker-compose.vue_nuxt.yaml.dis .ddev/docker-compose.vue_nuxt.yaml
```

_Note_: _Npm_ is included in the docker service and used to install this project,
if you want to install the project locally (npm install), edit and switch
__command__ line in __.ddev/docker-compose.vue_nuxt.yaml__ file.
To avoid re-install on each restart you can switch the __command__ after the first
launch.

Change Nuxt script values in __package.json__:

```json
"scripts": {
  "dev": "HOST=0.0.0.0 node_modules/.bin/nuxt",
```

Set Nuxt values in __contenta_vue_nuxt/nuxt.config.js__, change __serverBaseUrl__:

```json
const serverBaseUrl = 'http://pm2:3000';
const serverFilesUrl = 'http://contenta.ddev.local';
```

```shell
ddev start
```

## Usage

For all ddev commands see [https://ddev.readthedocs.io/en/latest/users/cli-usage](https://ddev.readthedocs.io/en/latest/users/cli-usage)

ContentaCMS Backoffice

- [http://contenta.ddev.local](http://contenta.ddev.local)

ContentaJS

- [http://contenta.ddev.local:3000/api](http://contentajs.ddev.local:3000/api)

If installed, access the vue frontend

- [http://front-vue.ddev.local](http://front-vue.ddev.local)

Docker web UI, you can access it on port 9000

- [http://contenta.ddev.local:9000](http://contenta.ddev.local:9000)

Redis commander on port 8081

- [http://contenta.ddev.local:8081](http://contenta.ddev.local:8081)

PhpMyAdmin on port 8036

- [http://contenta.ddev.local:8036](http://contenta.ddev.local:8036)

Mailhog on port 8025

- [http://contenta.ddev.local:8025](http://contenta.ddev.local:8025)

## Daily Usage

Drush with ContentaCMS

```shell
ddev exec drush status
ddev exec drush cr
```

Re-build ContentaJS (see __contentajs/package.json__ for more commands)

```shell
ddev exec -s pm2 npm run prepare
```

Use Composer with ContentaCMS

```shell
ddev exec composer --working-dir=/var/www/html/contentacms show -i contentacms/contenta_jsonapi
```

View logs, ssh in a container...

- [http://contenta.ddev.local:9000](http://contenta.ddev.local:9000)

## Issues

ContentaJS:

- Redis is not used with got (jsonrpc). Proxy is not using Redis.

Vue + Nuxt consumer:

- Menu loading not working.
