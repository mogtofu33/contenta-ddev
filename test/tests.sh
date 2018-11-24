#!/bin/bash
set -ev

# Test ContentaCMS
ddev exec drush status
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" -I http://contenta.ddev.local/api
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local/api
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local/api/pages

# Test ContentaJS
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" -I http://contenta.ddev.local:3000/api
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local:3000/api
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local:3000/api/pages

# Test Front VUE
curl -I http://front-vue.ddev.local

# Test Redis
curl -I http://contenta.ddev.local:8081
