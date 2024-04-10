FROM duplicati/duplicati:latest

RUN apt-get update && \
    apt-get install -y logrotate && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/duplicati.logrotate /etc/logrotate.d/duplicati

COPY files/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
