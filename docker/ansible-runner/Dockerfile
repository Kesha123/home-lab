FROM python:3.12-alpine AS builder

WORKDIR /workspace

ENV SSL_CERT_DIR=/etc/ssl/certs

COPY ansible-collections.yaml /tmp/
COPY requirements.in /tmp/

RUN apk add --no-cache \
      ca-certificates \
      libgcc \
      libstdc++ \
      build-base \
      cargo \
      rust \
    && update-ca-certificates --fresh

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir pip-tools==7.4.1 \
    && /opt/venv/bin/pip-compile /tmp/requirements.in -o /tmp/requirements.txt \
    && /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt \
    && /opt/venv/bin/ansible-galaxy collection install \
      -r /tmp/ansible-collections.yaml \
      -p /usr/share/ansible/collections

FROM python:3.12-alpine

WORKDIR /workspace

ENV SSL_CERT_DIR=/etc/ssl/certs
ENV PATH="/opt/venv/bin:${PATH}"

RUN apk add --no-cache ca-certificates libgcc libstdc++ \
    && update-ca-certificates --fresh \
    && addgroup -g 1000 -S ansible \
    && adduser -u 1000 -S -G ansible ansible \
    && chown -R ansible:ansible /workspace

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/share/ansible/collections /usr/share/ansible/collections
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

USER ansible

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD []
