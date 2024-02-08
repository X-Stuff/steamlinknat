#!/bin/sh

ln -s /var/opt/node/lib/node_modules/npm/bin/npm-cli.js /var/opt/node/bin/npm
ln -s /var/opt/node/lib/node_modules/npm/bin/npx-cli.js /var/opt/node/bin/npx

sed -i 's/\/usr\/bin\/env/\/bin\/env/g' /var/opt/node/lib/node_modules/npm/bin/npx-cli.js
sed -i 's/\/usr\/bin\/env/\/bin\/env/g' /var/opt/node/lib/node_modules/npm/bin/npm-cli.js
