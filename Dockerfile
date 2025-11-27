# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/python-base:2024.1@sha256:5f8be87b331508e33d7f048503184932d5099a583aba93dbe411df785c2055bf AS requirements
# renovate: name=openstack/requirements repo=https://github.com/openstack/requirements.git branch=stable/2024.1
ARG REQUIREMENTS_GIT_REF=0cbeda0d64ed79d76ad0c24ca4d16bad7313aae6
ADD --keep-git-dir=true https://github.com/openstack/requirements.git#${REQUIREMENTS_GIT_REF} /src/requirements
RUN cp /src/requirements/upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance_store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:2024.1@sha256:5f8be87b331508e33d7f048503184932d5099a583aba93dbe411df785c2055bf
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
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY --from=requirements --link /upper-constraints.txt /upper-constraints.txt
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
