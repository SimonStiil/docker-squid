ARG IMAGE_FROM=alpine:3.21.3
FROM $IMAGE_FROM

ENV SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=squid

RUN apk update && apk add --no-cache squid bash&& /usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 20MB && chown -R $SQUID_USER /var/lib/ssl_db

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
