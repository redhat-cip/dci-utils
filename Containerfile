FROM centos:stream8

LABEL name="dci-utils"
LABEL version="1.0.0"
LABEL maintainer="DCI Team <distributed-ci@redhat.com>"

ENV LANG en_US.UTF-8

RUN dnf upgrade -y && \
  dnf -y install epel-release https://packages.distributed-ci.io/dci-release.el8.noarch.rpm && \
  dnf -y install dci-downloader jq && \
  dnf clean all

ADD check_kernel.sh /usr/local/bin

CMD ["dci-downloader --help"]
