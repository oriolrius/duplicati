FROM duplicati/duplicati:2.1.0.107
LABEL org.opencontainers.image.source="https://github.com/oriolrius/duplicati"

RUN apt-get update && \
    apt-get install -y logrotate bash curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/duplicati.logrotate /etc/logrotate.d/duplicati

COPY files/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
