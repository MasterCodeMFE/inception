FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install -y \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/init.sql /etc/mysql/init.sql
COPY ./tools/script.sh /script.sh

RUN mkdir -p /run/mysqld && \
	chmod +x /script.sh && \
	chown -R mysql:mysql /var/lib/mysql /run/mysqld

EXPOSE 3306

CMD ["/script.sh"]
