"""Модульні тести парсера (без мережі): перевірка розбору рядків і перерахунку одиниць."""
import pytest

import parser

SAMPLE = """Connecting to host lab7-server, port 5201
[  5] local 172.20.0.3 port 41526 connected to 172.20.0.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  11.2 MBytes  93.9 Mbits/sec    0    255 KBytes
[  5]   1.00-2.00   sec  1.25 GBytes  10.7 Gbits/sec    3   1.50 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-2.00   sec  1.26 GBytes  5.40 Gbits/sec    3             sender
[  5]   0.00-2.00   sec  1.26 GBytes  5.40 Gbits/sec                  receiver
"""


def test_only_interval_lines_are_parsed():
    assert [v['Interval'] for v in parser.parser(SAMPLE)] == ['0.00-1.00', '1.00-2.00']


def test_values_and_units():
    a, b = parser.parser(SAMPLE)
    assert a == {'Interval': '0.00-1.00', 'Transfer': 11.2, 'Bitrate': 93.9, 'Retr': 0.0, 'Cwnd': 255.0}
    assert b['Transfer'] == 1280.0 and b['Bitrate'] == 10700.0 and b['Cwnd'] == 1536.0 and b['Retr'] == 3.0


@pytest.mark.parametrize('text', ['', 'iperf3: error - unable to connect to server: Connection refused\n'])
def test_no_intervals_in_error_or_empty_output(text):
    assert parser.parser(text) == []
