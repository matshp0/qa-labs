FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server iperf3 python3 python3-venv python3-pip procps iputils-ping ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && python3 -m venv /opt/venv && /opt/venv/bin/pip install --no-cache-dir pytest paramiko \
 && mkdir -p /run/sshd && ssh-keygen -A \
 && useradd -m -u 1000 -s /bin/bash matshp \
 && useradd -m -s /bin/bash qa && echo 'qa:qa-lab7-test' | chpasswd
ENV PATH=/opt/venv/bin:$PATH
WORKDIR /lab
