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
    --mount=type=bind,from=ghcr.io/vexxhost/build-utils:latest@sha256:287aa63d116f9e49c525b52aa9ffed40c292bb089190c6f348992dfed5cb0646,source=/bin,target=/build \
    /build/install-bindep-packages
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:b1e699368d24c57cda93c338a57a8c5a119009ba809305cc8e86986d4a006754 /uv /uvx /bin/
COPY --from=upper-constraints --link /upper-constraints.txt /upper-constraints.txt
RUN <<EOF bash -xe
uv venv --system-site-packages /var/lib/openstack
uv pip install \
    --constraint /upper-constraints.txt \
        cryptography \
        pymysql \
        python-binary-memcached \
        python-memcached \
        setuptools \
        uwsgi
EOF
