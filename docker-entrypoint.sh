#!/usr/bin/env bash

echo "Starting entrypoint script..."

if [ -z ${SERVER_BLOCK+x} ]; then
  echo "SERVER_BLOCK environment variable is not configured, provide the target server configuration."
  exit 1
fi

if [ -z ${ENABLE_ALL_PLUGINS+x} ]; then
  echo "Leaving OpenKore plugins default configuration"
else
  echo "Enabling all OpenKore plugins"
  sed -i 's/loadPlugins 2/loadPlugins 1/g' control/sys.txt
fi

cat >> /opt/openkore/tables/servers.txt <<EOF
echo $SERVER_BLOCK
EOF

exec "$@"
