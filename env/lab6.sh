#!/bin/bash
# Lab 6: encapsulation / decapsulation for one HTTP session. pc1 = router/DHCP/web server, pc2 = client. Runs inside run.sh (user+net namespaces, no sudo).
cd "$(dirname "$0")"; E=$(cd ..; pwd)/lab6/evidence; mkdir -p "$E"; rm -f "${E:?}"/*; printf "timeout 8;\nretry 2;\n" > $E/dhclient.conf; : > $E/log.txt
L() { echo "$*" | tee -a $E/log.txt; }
R() { echo "\$ $*" | tee -a $E/log.txt; "$@" 2>&1 | tee -a $E/log.txt; echo | tee -a $E/log.txt; }
L "Користувач: ${USER:-matshp} (група ІМ-34), хост: $(hostname)"; L "Дата: $(TZ=Europe/Kyiv date "+%Y-%m-%d %H:%M:%S %Z")"; echo | tee -a $E/log.txt
L "=== 1. PC1 and PC2 connected by Ethernet (veth) ==="
R ip -n pc1 -br link show eth0; R ip -n pc2 -br link show eth0
L "=== 2. DHCP server on PC1 (dnsmasq) ==="
printf '%s\n' "dhcp-range=10.0.0.10,10.0.0.20,255.255.255.0,600s" "dhcp-option=option:router,10.0.0.1" "dhcp-option=option:dns-server,8.8.8.8" > $E/dnsmasq.conf
cat $E/dnsmasq.conf | tee -a $E/log.txt
LD_PRELOAD=$PWD/nodrop.so ip netns exec pc1 dnsmasq -C $E/dnsmasq.conf --port=0 --interface=eth0 --bind-interfaces --user=root --pid-file=$E/dm.pid --dhcp-leasefile=$E/dhcpd.leases --log-dhcp --log-facility=$E/dnsmasq.log
echo | tee -a $E/log.txt
L "=== 3. NAT on PC1 ==="
R ip netns exec pc1 sysctl -w net.ipv4.ip_forward=1
R ip netns exec pc1 iptables -t nat -A POSTROUTING -o wan0 -s 10.0.0.0/24 -j MASQUERADE
R ip netns exec pc1 iptables -t nat -L POSTROUTING -n
L "=== 4. Wireshark (tshark) capture on PC1 eth0 ==="
ip netns exec pc1 tshark -q -i eth0 -a duration:30 -w $E/session.pcapng 2>/dev/null & CAP=$!
sleep 2
L "=== 5. dhclient on PC2 ==="
ip -n pc2 addr flush dev eth0
ip netns exec pc2 dhclient -1 -v -i -sf $PWD/dhcp-script.sh -lf $E/dhclient.leases -pf $E/dhc.pid -cf $E/dhclient.conf eth0 2>&1 | tee -a $E/log.txt
ip netns exec pc2 dhclient -x -pf $E/dhc.pid 2>/dev/null; echo | tee -a $E/log.txt
L "=== 7. default gateway on PC2 ==="
R ip netns exec pc2 ip route
L "=== 8. IP address of PC2 ==="
R ip netns exec pc2 ip -br addr show eth0
L "=== 9. ping PC2 from PC1 ==="
PC2IP=$(ip netns exec pc2 ip -4 -o addr show eth0 | awk '{print $4}' | cut -d/ -f1)
R ip netns exec pc1 ping -c 2 -W 1 $PC2IP
L "=== HTTP session: web server on PC1, request from PC2 ==="
ip netns exec pc1 python3 $PWD/webserver.py & WS=$!
sleep 1
R ip netns exec pc1 ip neigh flush all; R ip netns exec pc2 ip neigh flush all
L "(ARP caches cleared on both PCs, so ARP is visible again before the HTTP request)"
R ip netns exec pc2 curl -s -v --compressed --max-time 5 http://10.0.0.1/ http://10.0.0.1/second
sleep 2; kill $WS $(cat $E/dm.pid) 2>/dev/null; wait $CAP 2>/dev/null
L "=== captured packets ==="
ip netns exec pc1 tshark -r $E/session.pcapng 2>/dev/null | sed 's/^ *//' | tee $E/packets.txt
