#!/bin/bash
set -e

echo "Comprobando variables de entorno necesarias..."
if [ -z "${DB_HOST}" ] || [ -z "${DB_USER}" ] || [ -z "${DB_PASSWORD}" ] || [ -z "${DB_NAME}" ]; then
  echo "Error: Faltan variables de entorno necesarias."
  exit 1
fi

echo "Esperando a que MariaDB esté lista..."
until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
  echo "MariaDB no está lista aún, esperando..."
  sleep 2
done

echo "MariaDB está lista."

# Descargar wp-cli si no existe
if [ ! -f /usr/local/bin/wp ]; then
  echo "Descargando wp-cli..."
  curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x /usr/local/bin/wp
  echo "wp-cli descargado y listo."
fi

# Comprobar si WordPress está instalado
if ! wp core is-installed --path=/var/www/html --allow-root; then
  echo "WordPress no está instalado. Instalando..."
  wp core download --path=/var/www/html --allow-root
  
  # Crear configuración con configuraciones adicionales de seguridad y rendimiento
  wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$DB_HOST" --path=/var/www/html --allow-root --extra-php <<PHP
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);
define('SCRIPT_DEBUG', false);
define('WP_CACHE', true);
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);
define('CONCATENATE_SCRIPTS', true);
define('ENFORCE_GZIP', true);
define('AUTOMATIC_UPDATER_DISABLED', true);
define('WP_AUTO_UPDATE_CORE', false);
define('DISALLOW_FILE_EDIT', true);
define('FORCE_SSL_ADMIN', true);
PHP
  
  wp core install --url="$WORDPRESS_URL" --title="$WORDPRESS_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --path=/var/www/html --allow-root
  echo "WordPress instalado correctamente."

  # Crear usuario adicional
  wp user create "$WORDPRESS_USER_NAME" "$WORDPRESS_USER_EMAIL" --user_pass="$WORDPRESS_USER_PASSWORD" --role=author --path=/var/www/html --allow-root
  echo "Usuario adicional creado correctamente."
  
  # Instalar y activar el tema twentytwentythree
  echo "Instalando y activando tema Twenty Twenty-Three..."
  wp theme install twentytwentythree --activate --path=/var/www/html --allow-root
  echo "Tema Twenty Twenty-Three instalado y activado correctamente."
  
  # Configuraciones adicionales de WordPress para mejorar rendimiento
  wp option update blog_public 1 --path=/var/www/html --allow-root
  wp option update default_ping_status closed --path=/var/www/html --allow-root
  wp option update default_comment_status closed --path=/var/www/html --allow-root
  
  # Establecer estructura de permalinks
  wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root
  wp rewrite flush --path=/var/www/html --allow-root
  
  echo "Configuraciones adicionales aplicadas."
else
  echo "WordPress ya está instalado."

  # Por si quieres forzar la creación del usuario por si se borra manualmente:
  if ! wp user get "$WORDPRESS_USER_NAME" --path=/var/www/html --allow-root > /dev/null 2>&1; then
    echo "Creando usuario adicional que no existía..."
    wp user create "$WORDPRESS_USER_NAME" "$WORDPRESS_USER_EMAIL" --user_pass="$WORDPRESS_USER_PASSWORD" --role=author --path=/var/www/html --allow-root
    echo "Usuario adicional creado correctamente."
  else
    echo "Usuario adicional ya existe."
  fi
  
  # Verificar y activar tema twentytwentythree si no está activo
  CURRENT_THEME=$(wp theme status --path=/var/www/html --allow-root | grep "Active theme" | awk '{print $3}')
  if [ "$CURRENT_THEME" != "twentytwentythree" ]; then
    echo "Activando tema Twenty Twenty-Three..."
    wp theme install twentytwentythree --activate --path=/var/www/html --allow-root 2>/dev/null || wp theme activate twentytwentythree --path=/var/www/html --allow-root
    echo "Tema Twenty Twenty-Three activado."
  else
    echo "Tema Twenty Twenty-Three ya está activo."
  fi
fi

# Asegurar permisos correctos
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Iniciando PHP-FPM..."
exec "$@"
