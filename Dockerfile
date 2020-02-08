FROM debian:stretch-slim

MAINTAINER harapeko.suiren@gmail.com

EXPOSE 80

#VOLUME /usr/share/nextdom

ENV locale-gen fr_FR.UTF-8
ENV APACHE_PORT 80
ENV APACHE_PORT 443
ENV MODE_HOST 0
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --yes --no-install-recommends systemd systemd-sysv mysql-server sed

RUN echo "127.0.1.1 $HOSTNAME" >> /etc/hosts && \
    apt-get install --yes --no-install-recommends software-properties-common gnupg wget && \
    add-apt-repository non-free && \
    wget -qO - http://debian.nextdom.org/debian/nextdom.gpg.key | apt-key add - && \
    echo "deb http://debian.nextdom.org/debian nextdom main" >/etc/apt/sources.list.d/nextdom.list

COPY init.sh /root/init.sh
RUN chmod +x /root/init.sh
CMD ["/root/init.sh"]
