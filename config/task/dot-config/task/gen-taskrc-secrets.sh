#!/bin/sh

mkdir -p ~/.config/task

cat <<EOF > ~/.config/task/taskrc.secret
sync.encryption_secret=$(pass task/encryption_secret)
sync.server.client_id=$(pass task/client_id)
sync.server.url=$(pass task/server_url)
EOF

