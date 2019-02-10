####################################################
# GOLANG BUILDER
####################################################
FROM golang:1.11 as go_builder

ARG DRWEB_KEY
ENV DRWEB_KEY=$DRWEB_KEY

COPY . /go/src/github.com/malice-plugins/drweb
WORKDIR /go/src/github.com/malice-plugins/drweb
RUN go get github.com/golang/dep/cmd/dep && dep ensure
RUN go build -ldflags "-s -w -X main.LicenseKey=${DRWEB_KEY} -X main.Version=v$(cat VERSION) -X main.BuildTime=$(date -u +%Y%m%d)" -o /bin/avscan

####################################################
# PLUGIN BUILDER
####################################################
FROM debian:jessie-slim

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

ENV DRWEB 11.0.6

# Install Dr.WEB AV
# COPY drweb-11.0.5-av-linux-amd64.run /tmp/drweb-11.0.5-av-linux-amd64.run
RUN buildDeps='libreadline-dev:i386 \
    ca-certificates \
    libc6-dev:i386 \
    build-essential \
    gcc-multilib \
    cabextract \
    mercurial \
    git-core \
    unzip \
    wget' \
    && set -x \
    && dpkg --add-architecture i386 && apt-get update -qq \
    && apt-get install -y $buildDeps psmisc gnupg libc6-i386 libfontconfig1 libxrender1 libglib2.0-0 libxi6 xauth \
    # && apt-get install -yq libc6-i386 $buildDeps --no-install-recommends \
    && set -x \
    && echo "Install Dr Web..." \
    && cd /tmp \
    && wget --progress=bar:force https://download.geo.drweb.com/pub/drweb/unix/workstation/11.0/drweb-${DRWEB}-av-linux-amd64.run \
    && chmod 755 /tmp/drweb-${DRWEB}-av-linux-amd64.run \
    && DRWEB_NON_INTERACTIVE=yes /tmp/drweb-${DRWEB}-av-linux-amd64.run \
    && echo "===> Clean up unnecessary files..." \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/*

# Ensure ca-certificates is installed for elasticsearch to use https
RUN apt-get update -qq && apt-get install -yq --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY drweb.ini /etc/opt/drweb.com/drweb.ini

ARG DRWEB_KEY
ENV DRWEB_KEY=$DRWEB_KEY

RUN if [ "x$DRWEB_KEY" != "x" ]; then \
    echo "===> Adding Dr.WEB License Key..."; \
    /opt/drweb.com/bin/drweb-configd -d -p /var/run/drweb-configd.pid; \
    /opt/drweb.com/bin/drweb-ctl license --GetRegistered "$DRWEB_KEY"; \
    kill $(cat /var/run/drweb-configd.pid); \
    else \
    echo "===> Running Dr.WEB as DEMO..."; \
    /opt/drweb.com/bin/drweb-configd -d -p /var/run/drweb-configd.pid; \
    /opt/drweb.com/bin/drweb-ctl license --GetDemo; \
    kill $(cat /var/run/drweb-configd.pid); \
    fi

# Update Dr.WEB Definitions
RUN mkdir -p /opt/malice \
    && /opt/drweb.com/bin/drweb-configd -d -p /var/run/drweb-configd.pid \
    && drweb-ctl update \
    && kill $(cat /var/run/drweb-configd.pid)

# Add EICAR Test Virus File to malware folder
ADD http://www.eicar.org/download/eicar.com.txt /malware/EICAR

COPY --from=go_builder /bin/avscan /bin/avscan

EXPOSE 4443

WORKDIR /malware

ENTRYPOINT ["/bin/avscan"]
CMD ["--help"]
