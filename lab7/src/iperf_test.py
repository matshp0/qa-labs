import os

import parser

MIN_TRANSFER = float(os.environ.get('LAB7_MIN_TRANSFER', '2'))     # MBytes
MIN_BITRATE = float(os.environ.get('LAB7_MIN_BITRATE', '20'))      # Mbits/sec


class TestSuite():

    def test_iperf3_client_connection(self, client):
        """TC-7.1: перевіряємо, що клієнт не повертає помилку, а кожен інтервал iperf3
        має Transfer > 2 MBytes і Bitrate > 20 Mbits/sec.
        :param client: фікстура клієнта -> (stdout, stderr)"""
        out, err = client
        assert err == '', f'iperf3-клієнт повернув помилку: {err.strip()}'
        intervals = parser.parser(out)
        assert intervals, 'у виводі iperf3 немає жодного інтервалу'
        for value in intervals:
            assert value['Transfer'] > MIN_TRANSFER, (
                f"інтервал {value['Interval']}: Transfer {value['Transfer']} MB <= {MIN_TRANSFER} MB")
            assert value['Bitrate'] > MIN_BITRATE, (
                f"інтервал {value['Interval']}: Bitrate {value['Bitrate']} Mbit/s <= {MIN_BITRATE} Mbit/s")
