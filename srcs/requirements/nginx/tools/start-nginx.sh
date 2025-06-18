#!/bin/bash

# Generar certificados SSL autofirmados si no existen
if [ ! -f /etc/nginx/ssl/manuel.42.fr.crt ]; then
    echo "Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/manuel.42.fr.key \
        -out /etc/nginx/ssl/manuel.42.fr.crt \
        -subj "/C=ES/ST=Bizkaia/L=Bilbao/O=42/OU=IT/CN=${WORDPRESS_DOMAIN}"
fi

# Sustituir variables de entorno en la configuración de Nginx
envsubst '${WORDPRESS_DOMAIN}' < /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default

# Eliminar configuración por defecto y activar nuestra configuración
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Verificar configuración de Nginx
nginx -t

# Iniciar Nginx
exec nginx -g "daemon off;"
