FROM ghcr.io/vexxhost/ubuntu:edge@sha256:42ad7fa6cc255d5c4212d49f9d3193a6448ce8acfe0937738b5753a2c8159a7a AS requirements
# renovate: name=openstack/requirements repo=https://opendev.org/openstack/requirements.git branch=stable/2024.1
ARG REQUIREMENTS_GIT_REF=c1cde0f897da8c355d03eacda5cf3b610fe75e2c
ADD https://opendev.org/openstack/requirements/raw/commit/${REQUIREMENTS_GIT_REF}/upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i 's/PyMySQL=.*/PyMySQL===1.1.1/g' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:caracal@sha256:a723b028a3fb4f49fb4b0522240d04333f256e2e618c2fbdd62b6b4b047eb677
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
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
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:3362a526af7eca2fcd8604e6a07e873fb6e4286d8837cb753503558ce1213664 /uv /uvx /bin/
COPY --from=requirements --link /upper-constraints.txt /upper-constraints.txt
RUN \
  --mount=type=cache,target=/root/.cache/uv \
    uv venv --system-site-packages /var/lib/openstack && \
    uv pip install \
      --constraint /upper-constraints.txt \
        cryptography \
        pymysql \
        python-binary-memcached \
        python-memcached \
        uwsgi
