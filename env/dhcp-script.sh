#!/bin/bash
# minimal dhclient-script: only prints and applies lease on $interface (no resolv.conf changes)
m2p() { local b=0 o; IFS=. read -r -a O <<<"$1"; for o in "${O[@]}"; do while [ $o -gt 0 ]; do b=$((b+(o&1))); o=$((o>>1)); done; done; echo $b; }
case "$reason" in
 BOUND|RENEW|REBIND|REBOOT)
  ip addr flush dev $interface
  ip addr add $new_ip_address/$(m2p $new_subnet_mask) dev $interface
  [ -n "$new_routers" ] && ip route add default via ${new_routers%% *} dev $interface 2>&1
  echo "LEASE: ip=$new_ip_address mask=$new_subnet_mask router=$new_routers dns=$new_domain_name_servers lease=${new_dhcp_lease_time}s server=$new_dhcp_server_identifier" ;;
 *) echo "dhclient reason=$reason";;
esac
exit 0
