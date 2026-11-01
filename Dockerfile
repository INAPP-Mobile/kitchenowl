# KitchenOwl on Railway — wrapper around the pinned upstream image.
#
# Why a wrapper at all (house style: bake constants, keep the deploy form
# zero-field, and survive Railway's root-owned volumes):
# - PORT: Railway injects PORT; the upstream image's uWSGI public socket
#   is fixed at 8080 ([web] http = [::]:8080 in wsgi.ini). entrypoint.sh
#   rewrites that line to $PORT before execing the upstream entrypoint,
#   the same pattern as the LimeSurvey PORT->LISTEN_PORT fix. Without
#   this, Railway's healthcheck and public proxy would probe a port
#   nothing listens on. The internal backend socket (:5000) is untouched.
# - USER root: the upstream image already runs as root (python:3.14-slim,
#   no USER directive), so Railway's root-owned /data volume is writable
#   with no UID juggling. Keep root.
# - STORAGE_PATH=/data: upstream defaults put the SQLite database at
#   /data/database.db and uploads at /data/upload — both on the single
#   Railway volume (one volume per service), so restarts never wipe the
#   household data. Baked as ENV.
# - JWT_SECRET_KEY: the upstream default PLEASE_CHANGE_ME is insecure.
#   The template variable ${{secret(32)}} replaces it; it is the only
#   template variable, so the deploy form is zero-field.
# - Baked constants: DB_DRIVER=sqlite (default), OPEN_REGISTRATION=false
#   (default — after first-owner onboarding, public signup stays closed),
#   EMAIL_MANDATORY=false (default — onboarding is username-only, no
#   email verification step), COLLECT_METRICS=false (no Prometheus
#   endpoint), DISABLE_ONBOARDING unset (default false — first-run
#   onboarding stays open so the deployer can create the owner account).
# - FRONT_URL intentionally unset: the Flutter web app calls same-origin
#   /api paths, so no CORS allow-origin header is needed. Setting it from
#   a ${{RAILWAY_PUBLIC_DOMAIN}} self-reference risks the bare-https://
#   failure proven by the Spliit template; a set-but-broken value is
#   worse than unset here.
# - No Docker HEALTHCHECK: rely on Railway's external healthcheckPath,
#   which is the upstream image's own Docker HEALTHCHECK target
#   (/api/health/<fixed-token>, unauthenticated).
#
# Upstream: KitchenOwl v0.7.10 (AGPL-3.0), image pinned by manifest
# digest (amd64+arm64), verified 2026-11-01 via the Docker Hub API
# (matches the digest pinned by the existing marketplace template).

FROM tombursch/kitchenowl:v0.7.10@sha256:bd821a41b8cb27fd7fcf429acd1fc67e9f889485a2cd1193d68c2d804a8e1bef

USER root

# Baked constants (see header). JWT_SECRET_KEY comes from the template
# variable; everything else is fixed so the deploy form stays empty.
ENV STORAGE_PATH=/data \
    DB_DRIVER=sqlite \
    OPEN_REGISTRATION=false \
    EMAIL_MANDATORY=false \
    COLLECT_METRICS=false

COPY entrypoint.sh /usr/local/bin/ko-entrypoint.sh
RUN chmod +x /usr/local/bin/ko-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/ko-entrypoint.sh"]
CMD ["--ini", "wsgi.ini:web", "--gevent", "200", "--max-fd", "1048576"]
