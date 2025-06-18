#!/bin/bash
set -e

# Variables de entorno
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

echo "Iniciando configuración de MariaDB..."

# Verificar si es la primera instalación o si necesita configuración
if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "Primera instalación detectada. Inicializando base de datos..."
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    fi
    
    echo "Configurando base de datos..."
    
    # Iniciar MariaDB temporalmente para configuración
    mariadbd --user=mysql --skip-networking --socket=/tmp/mysql_init.sock &
    MYSQL_PID=$!
    
    # Esperar a que MySQL esté listo
    echo "Esperando a que MariaDB esté lista para configuración..."
    until mariadb-admin ping --socket=/tmp/mysql_init.sock --silent; do
        sleep 1
    done
    
    echo "MariaDB lista. Configurando usuarios y base de datos..."
    
    # Configurar la base de datos
    mariadb --socket=/tmp/mysql_init.sock -u root <<EOF_SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF_SQL
    
    echo "Configuración completada. Cerrando MariaDB temporal..."
    
    # Cerrar MariaDB temporal
    mariadb-admin --socket=/tmp/mysql_init.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $MYSQL_PID
    
    echo "Configuración inicial completada."
else
    echo "Base de datos existente y configurada encontrada."
fi

echo "Iniciando MariaDB en modo producción..."

# Iniciar MariaDB de forma permanente
exec mariadbd --user=mysql --console
