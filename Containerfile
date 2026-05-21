# syntax=docker/dockerfile:1

#FROM registry.access.redhat.com/ubi10/ubi
FROM rockylinux/rockylinux:10-ubi-init

# default configuration
ENV NTP_DIRECTIVES="ratelimit\nrtcsync"

# install chrony + timezone data
RUN set -eux && \
    dnf -y update && \
    dnf -y install \
        chrony \
        tzdata && \
    dnf clean all && \
    rm -f /etc/chrony.conf && \
    rm -rf /var/cache/dnf /tmp/*

# create chrony runtime user/group if not already present
RUN getent group chrony || groupadd -r chrony && \
    id chrony || useradd -r -g chrony -s /sbin/nologin chrony

# script to configure/startup chrony (ntp)
COPY --chmod=0755 assets/startup.sh /bin/startup

# ntp port
EXPOSE 123/udp

# writable volumes
VOLUME ["/etc/chrony", "/run/chrony", "/var/lib/chrony"]

# start chronyd in foreground
ENTRYPOINT ["/bin/startup"]
