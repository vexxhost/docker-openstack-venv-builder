FROM ghcr.io/vexxhost/ubuntu:edge@sha256:42ad7fa6cc255d5c4212d49f9d3193a6448ce8acfe0937738b5753a2c8159a7a AS requirements
# renovate: name=openstack/requirements repo=https://opendev.org/openstack/requirements.git branch=unmaintained/zed
ARG REQUIREMENTS_GIT_REF=1a3b0b7508e206c1863f5a700c1e359728010a61
ADD https://opendev.org/openstack/requirements/raw/commit/${REQUIREMENTS_GIT_REF}/upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i 's/PyMySQL=.*/PyMySQL===1.1.1/g' /upper-constraints.txt
EOF

FROM ghcr.io/vexxhost/python-base:zed@sha256:3da3b7ecd42f90c67943e213cebfc3ba33d97154c17d5d5d192429662ada9db7
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
