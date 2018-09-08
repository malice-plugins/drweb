####################################################
# GOLANG BUILDER
####################################################
FROM golang:1.11 as go_builder

COPY . /go/src/github.com/malice-plugins/drweb
WORKDIR /go/src/github.com/malice-plugins/drweb
RUN go get github.com/golang/dep/cmd/dep && dep ensure
RUN go build -ldflags "-s -w -X main.Version=v$(cat VERSION) -X main.BuildTime=$(date -u +%Y%m%d)" -o /bin/avscan

####################################################
# PLUGIN BUILDER
####################################################
FROM ubuntu:xenial

LABEL maintainer "https://github.com/blacktop"

LABEL malice.plugin.repository = "https://github.com/malice-plugins/drweb.git"
LABEL malice.plugin.category="av"
LABEL malice.plugin.mime="*"
LABEL malice.plugin.docker.engine="*"

# Create a malice user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN groupadd -r malice \
    && useradd --no-log-init -r -g malice malice \
    && mkdir /malware \
    && chown -R malice:malice /malware
# Install Dr.WEB AV
RUN set -x \
    && apt-get update -qq \
    && apt-get install -yq libfontconfig1 libxrender1 libglib2.0-0 libxi6 xauth gnupg \
    && set -x \
    && echo "Install Dr Web..." \
    && echo 'deb http://repo.drweb.com/drweb/debian 11.0 non-free' >> /etc/apt/sources.list \
    && apt-key adv --fetch-keys http://repo.drweb.com/drweb/drweb.key \
    && apt-get update -q && apt-get install -y drweb-file-servers \
    && drweb-ctl --version

#COPY drweb.ini /etc/opt/drweb.com/drweb.ini

ARG DRWEB_KEY
ENV DRWEB_KEY=$DRWEB_KEY

RUN if [ "x$DRWEB_KEY" != "x" ]; then \
    echo "===> Adding Dr.WEB License Key..."; \
    /opt/drweb.com/bin/drweb-configd -d -p /var/run/drweb-configd.pid; \
    /opt/drweb.com/bin/drweb-ctl license --GetRegistered "$DRWEB_KEY"; \
    else \
    echo "===> Running Dr.WEB as DEMO..."; \
    /opt/drweb.com/bin/drweb-configd -d -p /var/run/drweb-configd.pid; \
    /opt/drweb.com/bin/drweb-ctl license --GetDemo; \
    fi

# Ensure ca-certificates is installed for elasticsearch to use https
RUN apt-get update -qq && apt-get install -yq --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Update Dr.WEB Definitions
# RUN mkdir -p /opt/malice && drweb-configd && drweb-ctl update

# Add EICAR Test Virus File to malware folder
ADD http://www.eicar.org/download/eicar.com.txt /malware/EICAR

COPY --from=go_builder /bin/avscan /bin/avscan

WORKDIR /malware

# ENTRYPOINT ["/bin/avscan"]
# CMD ["--help"]
