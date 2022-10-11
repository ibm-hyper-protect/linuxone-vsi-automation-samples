FROM ubuntu:18.04
RUN apt-get update && apt-get install -y wget openvpn psmisc
COPY vpn/* /vpn/
RUN chmod u+x /vpn/start-vpn.sh
WORKDIR /vpn
CMD ["sh", "/vpn/start-vpn.sh"]