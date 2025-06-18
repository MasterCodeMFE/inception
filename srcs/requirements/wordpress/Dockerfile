FROM debian:bookworm

# Instalar dependencias necesarias
RUN apt update && apt upgrade -y && apt install -y \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    default-mysql-client \
    unzip \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Añadir el repositorio de Sury para PHP 7.4
RUN curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg && \
    echo "deb https://packages.sury.org/php bookworm main" > /etc/apt/sources.list.d/php.list

# Instalar PHP 7.4 y extensiones necesarias
RUN apt update && apt install -y \
    php7.4-fpm \
    php7.4-mysqli \
    php7.4-dom \
    php7.4-mbstring \
    php7.4-zip \
    php7.4-gd \
    php7.4-xml \
    php7.4-imagick \
    php7.4-curl \
    php7.4-opcache \
    php7.4-intl \
    php7.4-bcmath \
    php7.4-soap && \
    rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios
RUN mkdir -p /run/php /var/log

# Copiar configuración de PHP-FPM
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copiar y hacer ejecutable el script de inicialización
COPY ./tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

# Crear directorio de trabajo
WORKDIR /var/www/html

# Establecer permisos correctos
RUN chown -R www-data:www-data /var/www/html

# Exponer puerto 9000 para PHP-FPM
EXPOSE 9000

# Establecer el script como ENTRYPOINT
ENTRYPOINT ["/usr/local/bin/script.sh"]

# Comando por defecto
CMD ["php-fpm7.4", "-F"]
