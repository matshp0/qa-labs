"""Парсер виводу iperf3-клієнта: повертає список інтервалів зі значеннями у MB та Mbit/s."""
import re

KEYS = ('Interval', 'Transfer', 'Bitrate', 'Retr', 'Cwnd')

# рядок одного інтервалу iperf3, наприклад:
# [  5]   1.00-2.00   sec  11.2 MBytes  93.9 Mbits/sec    0    255 KBytes
# підсумкові рядки (sender/receiver) не збігаються, бо закінчуються словом
REGEXP = re.compile(
    r'^\[\s*\d+\]\s+(?P<start>[0-9.]+)-(?P<end>[0-9.]+)\s+sec\s+'
    r'(?P<tr>[0-9.]+)\s+(?P<tru>[KMG]?)Bytes\s+'
    r'(?P<br>[0-9.]+)\s+(?P<bru>[KMG]?)bits/sec'
    r'(?:\s+(?P<retr>\d+)\s+(?P<cwnd>[0-9.]+)\s+(?P<cwu>[KMG]?)Bytes)?\s*$')

_TO_MB = {'': 1 / 1024 / 1024, 'K': 1 / 1024, 'M': 1.0, 'G': 1024.0}
_TO_MBIT = {'': 1e-6, 'K': 1e-3, 'M': 1.0, 'G': 1e3}
_TO_KB = {'': 1 / 1024, 'K': 1.0, 'M': 1024.0, 'G': 1024.0 * 1024}


def parser(output):
    """Повертає список словників {'Interval','Transfer'(MB),'Bitrate'(Mbit/s),'Retr','Cwnd'(KB)}."""
    result = []
    for line in output.splitlines():
        m = REGEXP.match(line.strip())
        if not m:
            continue
        result.append({
            'Interval': f"{m['start']}-{m['end']}",
            'Transfer': round(float(m['tr']) * _TO_MB[m['tru']], 3),
            'Bitrate': round(float(m['br']) * _TO_MBIT[m['bru']], 3),
            'Retr': float(m['retr']) if m['retr'] else 0.0,
            'Cwnd': round(float(m['cwnd']) * _TO_KB[m['cwu']], 1) if m['cwnd'] else 0.0,
        })
    return result
