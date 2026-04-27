# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

ARG FROM

FROM ${FROM} AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance_store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i '/networking-generic-switch/d' /upper-constraints.txt
sed -i '/tap-as-a-service/d' /upper-constraints.txt
sed -i 's/^XStatic-Angular-Bootstrap===.*/XStatic-Angular-Bootstrap===2.5.0.1/' /upper-constraints.txt
sed -i 's/^XStatic-Angular-FileUpload===.*/XStatic-Angular-FileUpload===12.2.13.2/' /upper-constraints.txt
sed -i 's/^XStatic-Angular-Gettext===.*/XStatic-Angular-Gettext===2.4.1.1/' /upper-constraints.txt
sed -i 's/^XStatic-Angular-lrdragndrop===.*/XStatic-Angular-lrdragndrop===1.0.2.7/' /upper-constraints.txt
sed -i 's/^XStatic-Angular-Schema-Form===.*/XStatic-Angular-Schema-Form===0.8.13.1/' /upper-constraints.txt
sed -i 's/^XStatic-Angular-UUID===.*/XStatic-Angular-UUID===0.0.4.1/' /upper-constraints.txt
sed -i 's/^XStatic-Angular-Vis===.*/XStatic-Angular-Vis===4.16.0.1/' /upper-constraints.txt
sed -i 's/^XStatic-Angular===.*/XStatic-Angular===1.8.2.3/' /upper-constraints.txt
sed -i 's/^XStatic-Bootstrap-Datepicker===.*/XStatic-Bootstrap-Datepicker===1.4.0.1/' /upper-constraints.txt
sed -i 's/^XStatic-Bootstrap-SCSS===.*/XStatic-Bootstrap-SCSS===3.4.1.1/' /upper-constraints.txt
sed -i 's/^XStatic-bootswatch===.*/XStatic-bootswatch===3.3.7.1/' /upper-constraints.txt
sed -i 's/^XStatic-D3===.*/XStatic-D3===3.5.17.1/' /upper-constraints.txt
sed -i 's/^XStatic-FileSaver===.*/XStatic-FileSaver===1.3.2.1/' /upper-constraints.txt
sed -i 's/^XStatic-Hogan===.*/XStatic-Hogan===2.0.0.5/' /upper-constraints.txt
sed -i 's/^XStatic-Jasmine===.*/XStatic-Jasmine===2.4.1.3/' /upper-constraints.txt
sed -i 's/^XStatic-JQuery.quicksearch===.*/XStatic-JQuery.quicksearch===2.0.3.3/' /upper-constraints.txt
sed -i 's/^XStatic-JQuery.TableSorter===.*/XStatic-JQuery.TableSorter===2.14.5.3/' /upper-constraints.txt
sed -i 's/^XStatic-JS-Yaml===.*/XStatic-JS-Yaml===3.13.1.2/' /upper-constraints.txt
sed -i 's/^XStatic-JSEncrypt===.*/XStatic-JSEncrypt===2.3.1.2/' /upper-constraints.txt
sed -i 's/^XStatic-Json2yaml===.*/XStatic-Json2yaml===0.1.1.1/' /upper-constraints.txt
sed -i 's/^XStatic-mdi===.*/XStatic-mdi===1.6.50.3/' /upper-constraints.txt
sed -i 's/^XStatic-objectpath===.*/XStatic-objectpath===1.2.1.1/' /upper-constraints.txt
sed -i 's/^XStatic-Rickshaw===.*/XStatic-Rickshaw===1.5.1.3/' /upper-constraints.txt
sed -i 's/^XStatic-roboto-fontface===.*/XStatic-roboto-fontface===0.8.0.1/' /upper-constraints.txt
sed -i 's/^XStatic-smart-table===.*/XStatic-smart-table===1.4.13.3/' /upper-constraints.txt
sed -i 's/^XStatic-term.js===.*/XStatic-term.js===0.0.7.1/' /upper-constraints.txt
sed -i 's/^XStatic-tv4===.*/XStatic-tv4===1.2.7.1/' /upper-constraints.txt
EOF

FROM ${FROM}
RUN --mount=type=bind,source=bindep.txt,target=/bindep.txt \
    --mount=type=bind,from=ghcr.io/vexxhost/build-utils:latest@sha256:18983b130c78bbdaf1e84dc607c00e91f8a8729ca1dd9c195c259ddea5f88f54,source=/bin,target=/build \
    /build/install-bindep-packages
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:3b7b60a81d3c57ef471703e5c83fd4aaa33abcd403596fb22ab07db85ae91347 /uv /uvx /bin/
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
