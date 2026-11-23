"""Фікстури для тестування iperf3: server (ssh + paramiko -> піднімає iperf3-сервер) і client (subprocess)."""
import os
import subprocess

import paramiko
import pytest

# Дані сервера (у лабораторному стенді - окремий контейнер lab7-server з sshd та iperf3)
SERVER_HOST = os.environ.get('LAB7_SSH_HOST', 'lab7-server')
USERNAME = os.environ.get('LAB7_SSH_USER', 'qa')
PASSWORD = os.environ.get('LAB7_SSH_PASSWORD', 'qa-lab7-test')   # тестовий пароль лабораторного контейнера
# Параметри клієнта (можна змінювати змінними оточення, щоб отримати позитивні й негативні результати)
SERVER_IP = os.environ.get('LAB7_SERVER_IP', SERVER_HOST)
PORT = os.environ.get('LAB7_PORT', '5201')
DURATION = os.environ.get('LAB7_DURATION', '5')
BITRATE = os.environ.get('LAB7_BITRATE')          # напр. 10M - обмежити швидкість клієнта


@pytest.fixture(scope='function')
def server():
    """Підключається по ssh до сервера, піднімає iperf3-сервер, після тесту зупиняє його і закриває ssh."""
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(SERVER_HOST, username=USERNAME, password=PASSWORD, timeout=10)
    _, stdout, stderr = ssh.exec_command('nohup iperf3 -s -1 -p 5201 > /tmp/iperf3_server.log 2>&1 &')
    stdout.channel.recv_exit_status()
    ssh.exec_command('sleep 1')[1].channel.recv_exit_status()   # дати серверу час підняти порт
    error = stderr.read().decode()
    yield error
    ssh.exec_command('pkill iperf3')[1].channel.recv_exit_status()
    ssh.close()                                                  # teardown: закриваємо ssh-з'єднання


@pytest.fixture(scope='function')
def client(server):
    """Запускає iperf3-клієнт (subprocess) і повертає (stdout, stderr) для аналізу."""
    cmd = ['iperf3', '-c', SERVER_IP, '-p', PORT, '-t', DURATION, '-i', '1']
    if BITRATE:
        cmd += ['-b', BITRATE]
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
    return proc.stdout, proc.stderr
