# GlitchTip on Railway: the official image, pinned by version and digest.
# To update: bump the tag and digest below, add a CHANGELOG.md entry, merge to main.
FROM glitchtip/glitchtip:7.0.0@sha256:c245745b4179667da3aebd73fb8d4f1fd918f7d68ba07d1fd73ea688933b6e01

# The start script runs as root only to fix the volume's ownership, then drops
# to the image's own unprivileged "app" user (uid 5000) for everything else.
USER root
COPY --chmod=755 railway-start.sh /code/bin/railway-start.sh
COPY --chmod=644 railway_bootstrap.py /code/bin/railway_bootstrap.py

EXPOSE 8000
CMD ["/code/bin/railway-start.sh"]
