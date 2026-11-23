# qa-labs

Lab work for «Тестування та контроль якості (QA) вбудованих систем» (КПІ ім. Ігоря Сікорського, ІМ-34).

| Dir | Lab | What is here |
|---|---|---|
| `lab6/` | ЛР6. Інкапсуляція та декапсуляція (HTTP) | report PDF, captured `session.pcapng`, logs, Wireshark/terminal screenshots |
| `lab7/` | ЛР7. Pytest | report PDF, `src/` (conftest.py, parser.py, iperf_test.py, iperf_client.py, test_parser.py), Dockerfile, `run_lab7.sh`, evidence |
| `env/` | helper scripts | virtual lab (network namespaces, no sudo) used by lab 6 |

## Reproduce
- **Lab 6:** build `nodrop.so` (`gcc -shared -fPIC env/nodrop.c -o env/nodrop.so -ldl`), then `./env/run.sh lab6` (needs dnsmasq, dhclient, tshark, iptables, curl, python3; runs in an unprivileged user+net namespace; output goes to `lab6/evidence/` next to `env/`).
- **Lab 7:** `cd lab7 && docker build -t qa-lab7 . && ./run_lab7.sh` (two containers on a private Docker network: sshd+iperf3 server, pytest+paramiko client). The ssh password in `conftest.py` is a test password of that local container only.

Both labs ran on virtual stands, not on physical hardware; the reports state the limits.
