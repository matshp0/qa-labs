"""Частина 1: client(server_ip) через subprocess + parser(); виводить інтервали з Transfer > 2 MB і Bitrate > 20 Mbit/s."""
import subprocess
import sys

import parser

server_ip = sys.argv[1] if len(sys.argv) > 1 else 'lab7-server'   # iperf3-сервер піднято вручну в іншому терміналі


def client(server_ip):
    """Підключається до iperf3-сервера. :return: (вивід, помилка)"""
    proc = subprocess.Popen(['iperf3', '-c', server_ip, '-t', '5', '-i', '1'],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return proc.communicate()


if __name__ == '__main__':
    result, error = client(server_ip)
    if error:
        print(error)
        sys.exit(1)
    for value in parser.parser(result):
        if value['Transfer'] > 2 and value['Bitrate'] > 20:
            print(value)
