FROM nginx:1.9.14
MAINTAINER Jeff Gonzalez <likwid at gmail>

EXPOSE 1025

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && \
    apt-get -y install wget runit unzip&& \
    rm -rf /var/lib/apt/lists/*

RUN wget --no-check-certificate https://releases.hashicorp.com/consul-template/0.13.0/consul-template_0.13.0_linux_amd64.zip \
    && unzip consul-template_0.13.0_linux_amd64.zip -d /usr/bin \
    && rm consul-template_0.13.0_linux_amd64.zip \
    && mkdir /opt/blue-green \
    && mkdir /etc/nginx/apps.d

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.service /etc/service/nginx/run
COPY consul-template.service /etc/service/consul-template/run
COPY consul-template.conf /consul-template.conf
COPY upstreams.tmpl /opt/blue-green/upstreams.tmpl
COPY vhosts.tmpl /opt/blue-green/vhosts.tmpl

CMD ["/usr/bin/runsvdir", "/etc/service"]
