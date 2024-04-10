FROM duplicati/duplicati:latest
LABEL org.opencontainers.image.source="https://github.com/oriolrius/duplicati"

RUN apt-get update && \
    apt-get install -y logrotate && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/duplicati.logrotate /etc/logrotate.d/duplicati

COPY files/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
