# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/python-base:main@sha256:ab85e44ce8c48b4b99a547b172f36790d9a184822abded588021fa079c263b47 AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance_store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i '/networking-generic-switch/d' /upper-constraints.txt
sed -i '/tap-as-a-service/d' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:main@sha256:ab85e44ce8c48b4b99a547b172f36790d9a184822abded588021fa079c263b47
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    build-essential \
    git \
    libldap2-dev \
    libpcre3-dev \
    libsasl2-dev \
    libssl-dev \
    lsb-release \
    openssh-client \
    python3 \
    python3-dev
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:9a23023be68b2ed09750ae636228e903a54a05ea56ed03a934d00fe9fbeded4b /uv /uvx /bin/
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
