#!/bin/bash

CERT_DIR="/home/manuel/data/certs"
CERT_KEY="$CERT_DIR/manuel.42.fr.key"
CERT_CRT="$CERT_DIR/manuel.42.fr.crt"
DB_DIR="/home/manuel/data/database"
WEB_DIR="/home/manuel/data/web"

# Crear carpetas necesarias si no existen y asignar permisos
for DIR in "$CERT_DIR" "$DB_DIR" "$WEB_DIR"; do
    if [ ! -d "$DIR" ]; then
        echo "Creando directorio: $DIR"
        mkdir -p "$DIR"
        # Asignar permisos completos para el usuario y el grupo de Docker
        chmod 777 "$DIR"
        echo "Permisos de $DIR configurados a 777."
    else
        echo "El directorio $DIR ya existe."
        # Asegurarse de que los permisos sean correctos incluso si ya existe
        chmod 777 "$DIR"
        echo "Permisos de $DIR asegurados a 777."
    fi
done

# Generar certificados si no existen
if [ ! -f "$CERT_KEY" ] || [ ! -f "$CERT_CRT" ]; then
    echo "No se encontraron certificados, generando..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_KEY" -out "$CERT_CRT" \
        -subj "/C=ES/ST=Andalucia/L=Sevilla/O=42/OU=Inception/CN=manuel.42.fr"
    echo "Certificados generados en $CERT_DIR."
else
    echo "Certificados ya existen en $CERT_DIR, no es necesario generarlos."
fi
