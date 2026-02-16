# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

ARG FROM

FROM ${FROM} AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i '/networking-generic-switch/d' /upper-constraints.txt
EOF

FROM ${FROM}
RUN --mount=type=bind,source=bindep.txt,target=/bindep.txt \
    --mount=type=bind,from=ghcr.io/vexxhost/build-utils:latest@sha256:79d7579c2300391cc9cdd9ca17b9031750a748fb84a87ebb1f1a920e1fcb4740,source=/bin,target=/build \
    /build/install-bindep-packages
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:7a88d4c4e6f44200575000638453a5a381db0ae31ad5c3a51b14f8687c9d93a3 /uv /uvx /bin/
COPY --from=upper-constraints --link /upper-constraints.txt /upper-constraints.txt
RUN <<EOF bash -xe
uv venv --system-site-packages /var/lib/openstack
uv pip install \
    --constraint /upper-constraints.txt \
        confluent-kafka \
        cryptography \
        pymysql \
        python-binary-memcached \
        python-memcached \
        uwsgi
EOF
