if [ "${1}" = "hpcr-sample-nginx-hello-domain" ]; then

   GUEST_IP=192.168.122.170
   GUEST_PORT=80
   HOST_PORT=80

   echo qemu-hook
   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
        /sbin/iptables -D LIBVIRT_INP -m state --state NEW -m tcp -p tcp --dport ${HOST_PORT} -j ACCEPT

        /sbin/iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
        /sbin/iptables -D FORWARD -p tcp -d $GUEST_IP -j LOG --log-level debug --log-prefix FORWARD

        /sbin/iptables -D LIBVIRT_FWI -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
        /sbin/iptables -D LIBVIRT_FWI -o virbr0 -d 192.168.122.0/24 -m state --state NEW -j ACCEPT

        /sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
        /sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j LOG --log-level debug --log-prefix PREROUTING

        /sbin/iptables -t nat -D LIBVIRT_PRT -p tcp --dport $HOST_PORT -j MASQUERADE -s $GUEST_IP -d $GUEST_IP
        /sbin/iptables -t nat -D LIBVIRT_PRT -p tcp --dport $HOST_PORT -s $GUEST_IP -d $GUEST_IP -j LOG --log-level debug --log-prefix LIBVIRT_PRT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
       
        /sbin/iptables -I LIBVIRT_INP -m state --state NEW -m tcp -p tcp --dport ${HOST_PORT} -j ACCEPT

        /sbin/iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
        /sbin/iptables -I FORWARD -p tcp -d $GUEST_IP -j LOG --log-level debug --log-prefix FORWARD

        /sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
        /sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j LOG --log-level debug --log-prefix PREROUTING
   fi
fi