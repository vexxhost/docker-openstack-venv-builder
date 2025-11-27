# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/python-base:2023.2@sha256:bddcab6ad70beb092dc9c67d799f8840fecd6bb1dcb6e7a07c62f8d46b817aa9 AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance_store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:2023.2@sha256:bddcab6ad70beb092dc9c67d799f8840fecd6bb1dcb6e7a07c62f8d46b817aa9
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    build-essential \
    curl \
    git \
    gnupg \
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
RUN curl -sL https://packages.confluent.io/clients/deb/archive.key | apt-key add - && \
    echo "deb https://packages.confluent.io/clients/deb/ jammy main" > /etc/apt/sources.list.d/confluent.list && \
    apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends librdkafka-dev && \
    apt-get clean && \
    rm -rf /etc/apt/sources.list.d/confluent.list /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:f07d1bf7b1fb4b983eed2b31320e25a2a76625bdf83d5ff0208fe105d4d8d2f5 /uv /uvx /bin/
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
