# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/python-base:zed@sha256:292acf003d3de43bc933efadc4f26527427258b4e618c59cb2b1eb46a9119adb AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:zed@sha256:292acf003d3de43bc933efadc4f26527427258b4e618c59cb2b1eb46a9119adb
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
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:5713fa8217f92b80223bc83aac7db36ec80a84437dbc0d04bbc659cae030d8c9 /uv /uvx /bin/
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
        setuptools \
        uwsgi
EOF
