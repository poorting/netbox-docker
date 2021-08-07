#!/usr/bin/env sh

# Copy NGINX conf files
docker cp netbox_nginx:/etc/nginx/conf.d/ etc/.

# Copy Let's Encrypt settings and certificates
docker cp netbox_nginx:/etc/letsencrypt/ etc/.


