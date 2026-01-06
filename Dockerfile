# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/python-base:2023.2@sha256:220d65e3184ef5a50978abac042c8b4e9cb15829dfd8d32249da2c544a101df1 AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:2023.2@sha256:220d65e3184ef5a50978abac042c8b4e9cb15829dfd8d32249da2c544a101df1
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
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:2320e6c239737dc73cccce393a8bb89eba2383d17018ee91a59773df802c20e6 /uv /uvx /bin/
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
