# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

ARG FROM

FROM ${FROM} AS upper-constraints
COPY --from=requirements upper-constraints.txt /upper-constraints.txt
RUN <<EOF sh -xe
sed -i '/glance-store/d' /upper-constraints.txt
sed -i '/horizon/d' /upper-constraints.txt
sed -i 's/^keystonemiddleware===.*/keystonemiddleware===10.8.0/' /upper-constraints.txt
sed -i 's/^PasteDeploy===.*/PasteDeploy===3.0.1/' /upper-constraints.txt
echo 'setuptools<82' >> /upper-constraints.txt
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
    --mount=type=bind,from=ghcr.io/vexxhost/build-utils:latest@sha256:b7cd2d8781e532a3c159eb835a41c50933f8c9faa14dcf1aac320f33481ce4b2,source=/bin,target=/build \
    /build/install-bindep-packages
COPY --from=ghcr.io/astral-sh/uv:latest@sha256:841c8e6fe30a8b07b4478d12d0c608cba6de66102d29d65d1cc423af86051563 /uv /uvx /bin/
COPY --from=upper-constraints --link /upper-constraints.txt /upper-constraints.txt
RUN <<EOF bash -xe
uv venv --system-site-packages /var/lib/openstack
uv pip install \
    --constraint /upper-constraints.txt \
        cryptography \
        pymysql \
        python-binary-memcached \
        python-memcached \
        setuptools \
        uwsgi
EOF
