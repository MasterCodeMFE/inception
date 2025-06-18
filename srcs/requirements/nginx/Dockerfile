FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install -y \
    nginx \
    openssl \
    gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Crear directorio para certificados SSL
RUN mkdir -p /etc/nginx/ssl && chmod 700 /etc/nginx/ssl

# Copiar configuración de Nginx
COPY ./conf/default /etc/nginx/sites-available/default.template

# Copiar y hacer ejecutable el script de inicio
COPY ./tools/start-nginx.sh /start-nginx.sh
RUN chmod +x /start-nginx.sh

# Exponer puerto 443
EXPOSE 443

# Comando por defecto
CMD ["/start-nginx.sh"]
