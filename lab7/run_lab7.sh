#!/bin/bash
# Lab 7: iperf3 + pytest. Two containers on a private docker network: lab7-server (sshd+iperf3), lab7-client (pytest, paramiko).
cd "$(dirname "$0")"; EV=$PWD/evidence; mkdir -p "$EV"; rm -f "${EV:?}"/*.txt
docker rm -f lab7-server lab7-client >/dev/null 2>&1; docker network rm lab7net >/dev/null 2>&1; docker network create lab7net >/dev/null
docker run -d --rm --name lab7-server --hostname lab7-server --network lab7net qa-lab7 /usr/sbin/sshd -D -e >/dev/null
docker run -d --rm --name lab7-client --hostname lab7-client --network lab7net -u 1000:1000 -e HOME=/tmp -v $PWD/src:/lab qa-lab7 sleep infinity >/dev/null
sleep 2
C() { docker exec -u 1000 -w /lab -e HOME=/tmp lab7-client bash -c "$*"; }
# rec <file> <cmd>: writes a "terminal" transcript with user + date
rec() { f=$EV/$1.txt; shift; { echo "matshp@lab7-client:/lab\$ date; whoami"; C "date; whoami"; echo "matshp@lab7-client:/lab\$ $*"; C "$*" 2>&1; } > $f 2>&1; cat $f; echo; }
rec 01_env "iperf3 --version | head -1; python3 --version; pytest --version; python3 -c 'import paramiko; print(\"paramiko\", paramiko.__version__)'; ls"
# --- Part 1: manual iperf3 (server raised manually in the server container), TCP + UDP
docker exec -d lab7-server bash -c 'iperf3 -s -1 > /tmp/srv_tcp.log 2>&1'; sleep 1
rec 02_manual_tcp "iperf3 -c lab7-server -t 5 -i 1"
sleep 1; docker exec lab7-server cat /tmp/srv_tcp.log > $EV/02_server_tcp.txt
docker exec -d lab7-server bash -c 'iperf3 -s -1 > /tmp/srv_udp.log 2>&1'; sleep 1
rec 03_manual_udp "iperf3 -c lab7-server -u -b 50M -t 5 -i 1"
sleep 1; docker exec lab7-server cat /tmp/srv_udp.log > $EV/03_server_udp.txt
# --- Part 1: python client() + parser()
docker exec -d lab7-server bash -c 'iperf3 -s -1 > /tmp/srv_py.log 2>&1'; sleep 1
rec 04_python_client "python3 iperf_client.py lab7-server"
# --- Part 2: pytest
rec 05_pytest_unit "pytest -v test_parser.py -p no:cacheprovider"
rec 06_pytest_pass "pytest -v iperf_test.py -p no:cacheprovider"
rec 07_pytest_fail_bitrate "LAB7_BITRATE=10M pytest -v iperf_test.py -p no:cacheprovider"
rec 08_pytest_fail_connect "LAB7_PORT=5999 pytest -v iperf_test.py -p no:cacheprovider"
rec 09_files "ls -l; wc -l conftest.py parser.py iperf_test.py iperf_client.py test_parser.py"
docker rm -f lab7-server lab7-client >/dev/null; docker network rm lab7net >/dev/null
rm -rf src/__pycache__ src/.pytest_cache
