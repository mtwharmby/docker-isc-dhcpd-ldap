FROM debian:stable-slim

LABEL author="Michael Wharmby <mtwharmby>"

RUN apt-get -q update
RUN apt-get -yq install isc-dhcp-server-ldap tini
RUN apt-get -q clean

ADD ./container /container

# 67/udp - dhcp; 547/tcp+udp - dhcp6
EXPOSE 67/udp
EXPOSE 547/tcp
EXPOSE 547/udp

# Should an IPv4 or IPv6 server be started?
# Set these to yes, no or empty stings
ENV IPV4="YES"
ENV IPV6="NO"

# ENTRYPOINT script ensures init process running
ENTRYPOINT [ "/container/init.sh" ]
CMD [ "/container/dhcpd-startup.sh" ]