FROM python:3.14-alpine AS builder

ENV SSL_CERT_DIR=/etc/ssl/certs

COPY requirements.in /tmp/

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir pip-tools==7.4.1 \
    && /opt/venv/bin/pip-compile /tmp/requirements.in -o /tmp/requirements.txt \
    && /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

FROM python:3.14-alpine AS runtime

ENV SSL_CERT_DIR=/etc/ssl/certs
ENV PATH="/opt/venv/bin:${PATH}"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --from=builder /opt/venv /opt/venv

RUN chmod +x /usr/local/bin/entrypoint.sh

USER 1000:1000

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD []
