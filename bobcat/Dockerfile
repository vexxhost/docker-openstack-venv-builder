FROM ghcr.io/vexxhost/ubuntu-cloud-archive:bobcat
# renovate: name=openstack/requirements repo=https://opendev.org/openstack/requirements.git branch=stable/2023.2
ARG REQUIREMENTS_GIT_REF=9042ccffadf3de68b5e2e0ee76e3d085842fd161
ADD https://opendev.org/openstack/requirements/raw/commit/${REQUIREMENTS_GIT_REF}/upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:bobcat
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
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
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
