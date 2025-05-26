FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY default /etc/nginx/sites-available/default

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

EXPOSE 443

CMD ["/usr/local/bin/entrypoint.sh"]
