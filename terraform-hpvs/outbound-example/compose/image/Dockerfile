FROM ubuntu:18.04
RUN apt-get update && apt-get install -y wget openvpn psmisc
COPY vpn/* /vpn/
WORKDIR /vpn
CMD ["sh", "/vpn/start_vpn.sh"]