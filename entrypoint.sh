#!/bin/bash
# KitchenOwl Railway wrapper entrypoint.
#
# Maps Railway's injected PORT onto uWSGI's public http socket (fixed
# 8080 upstream in wsgi.ini [web]) before handing off to the upstream
# entrypoint, which runs flask db upgrade, imports default items, and
# starts uWSGI with the original CMD args. The internal backend socket
# (:5000) and the celery worker/beat attached daemon are untouched.
# If PORT is unset (local runs), the upstream 8080 default stands.
set -e
cd /usr/src/kitchenowl

PORT="${PORT:-8080}"
sed -i "s/^http = .*$/http = [::]:${PORT}/" wsgi.ini

exec ./entrypoint.sh "$@"
