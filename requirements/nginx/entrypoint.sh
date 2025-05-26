#!/bin/bash

CERTS_DIR="/etc/nginx/certs"
KEY_FILE="${CERTS_DIR}/nginx.key"
CERT_FILE="${CERTS_DIR}/nginx.crt"

mkdir -p "$CERTS_DIR"

if [ ! -f "$KEY_FILE" ] || [ ! -f "$CERT_FILE" ]; then
    echo "Certificados no encontrados. Generando certificados autofirmados..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=MiOrganizacion/OU=MiUnidad/CN=localhost"
    echo "Certificados generados en: $CERTS_DIR"
else
    echo "Certificados existentes. Saltando la generación."
fi

exec nginx -g "daemon off;"
