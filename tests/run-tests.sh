#!/bin/bash
set -ev

# Test ContentaCMS
ddev exec drush status
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" -I http://contenta.ddev.local/api
# curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local/api
# curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local/api/pages

# Test ContentaJS
ddev logs -s pm2
curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" -I http://contenta.ddev.local:3000/api
# curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local:3000/api
# curl -H "Access-Control-Request-Method: GET" -H "Origin: http://contenta.ddev.local" http://contenta.ddev.local:3000/api/pages

# Test Front VUE
ddev logs -s vue_nuxt
curl -I http://front-vue.ddev.local
curl -I http://front-vue.ddev.local 2>/dev/null | head -n 1 | cut -d$' ' -f2

# Test Redis
curl -I http://contenta.ddev.local:8081 2>/dev/null | head -n 1 | cut -d$' ' -f2
