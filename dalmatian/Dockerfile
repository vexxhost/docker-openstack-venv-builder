FROM ghcr.io/vexxhost/ubuntu:edge@sha256:5569d9acb4dadc1e88e9c83efc44c131a648894ec3d3335e85e3ae526861e1bd AS requirements
# renovate: name=openstack/requirements repo=https://opendev.org/openstack/requirements.git branch=stable/2024.2
ARG REQUIREMENTS_GIT_REF=3a697f8e7a691db0c0a8cef883df130901338182
ADD https://opendev.org/openstack/requirements/raw/commit/${REQUIREMENTS_GIT_REF}/upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i '/PyMySQL=.*/PyMySQL==1.1.1/g' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:caracal@sha256:ebc288c9458780b7861ad3e02adc4d1cb39a5801e39a1bd6d27a17d954fdfa51
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
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:0b6dc79013b689f3bc0cbf12807cb1c901beaafe80f2ee10a1d76aa3842afb92 /uv /uvx /bin/
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
