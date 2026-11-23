#!/bin/bash
# Virtual lab: pc1 <-veth-> pc2 (10.0.0.0/24); pc1 <-veth-> inet (203.0.113.0/24, fake "Internet"). Isolated from the real network.
set -e
teardown() { for n in pc1 pc2 inet; do ip netns del $n 2>/dev/null || true; done; }
[ "$1" = down ] && { teardown; echo torn down; exit 0; }
teardown
for n in pc1 pc2 inet; do ip netns add $n; ip -n $n link set lo up; done
ip link add eth0 netns pc1 type veth peer name eth0 netns pc2
ip link add wan0 netns pc1 type veth peer name wan0 netns inet
ip -n pc1 link set eth0 address 02:00:00:00:00:01
ip -n pc2 link set eth0 address 02:00:00:00:00:02
ip -n pc1 addr add 10.0.0.1/24 dev eth0; ip -n pc1 link set eth0 up
ip -n pc2 link set eth0 up
ip -n pc1 addr add 203.0.113.2/24 dev wan0; ip -n pc1 link set wan0 up
ip -n inet addr add 203.0.113.1/24 dev wan0; ip -n inet link set wan0 up
ip -n inet addr add 8.8.8.8/32 dev lo
ip -n pc1 route add default via 203.0.113.1
echo up
