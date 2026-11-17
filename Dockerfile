# Monica 4.1.2 (latest stable; 5.x is still beta) in the official Docker Hub image,
# Apache variant, pinned by version and digest.
FROM monica:4.1.2-apache@sha256:9319157715ef21ce4206b7efcc66a74ce4ae0eed8859905e69e1be6105e4ecef

# Health check for Railway: GET /healthz answers 200 once Apache runs, which only
# happens after the image's entrypoint has run the database migrations.
COPY railway-healthz.conf /etc/apache2/conf-available/railway-healthz.conf
COPY healthz.txt /opt/railway/healthz.txt
COPY railway-start.sh railway-owner.php /usr/local/bin/
COPY apache2-railway /usr/local/bin/apache2-railway
RUN set -eux; \
    a2enconf railway-healthz; \
    chmod 0755 /usr/local/bin/railway-start.sh /usr/local/bin/apache2-railway; \
    chmod 0644 /usr/local/bin/railway-owner.php /opt/railway/healthz.txt

# All state (uploads, photos, documents, OAuth keys, logs) lives in
# /var/www/html/storage, which the template puts on a Railway volume.
# The data itself is in the MariaDB service.
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["apache2-railway"]
