# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

ARG FROM

FROM ${FROM} AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i 's/^keystonemiddleware===.*/keystonemiddleware===10.8.0/' /upper-constraints.txt
sed -i 's/^PasteDeploy===.*/PasteDeploy===3.0.1/' /upper-constraints.txt
echo 'setuptools<82' >> /upper-constraints.txt
EOF

FROM ${FROM}
RUN --mount=type=bind,source=bindep.txt,target=/bindep.txt \
    --mount=type=bind,from=ghcr.io/vexxhost/build-utils:latest@sha256:79d7579c2300391cc9cdd9ca17b9031750a748fb84a87ebb1f1a920e1fcb4740,source=/bin,target=/build \
    /build/install-bindep-packages
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:2f2ccd27bbf953ec7a9e3153a4563705e41c852a5e1912b438fc44d88d6cb52c /uv /uvx /bin/
COPY --from=upper-constraints --link /upper-constraints.txt /upper-constraints.txt
RUN <<EOF bash -xe
uv venv --system-site-packages /var/lib/openstack
uv pip install \
    --constraint /upper-constraints.txt \
        cryptography \
        pymysql \
        python-binary-memcached \
        python-memcached \
        uwsgi
EOF
