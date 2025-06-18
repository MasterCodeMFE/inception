all: clean
	rm -rf /home/manuel/data/*
	chmod +x ./srcs/requirements/tools/generate_certs.sh
	./srcs/requirements/tools/generate_certs.sh
	docker compose -f srcs/docker-compose.yml build
	docker compose -f srcs/docker-compose.yml up -d

build:
	rm -rf /home/manuel/data/*
	chmod +x ./srcs/requirements/tools/generate_certs.sh
	./srcs/requirements/tools/generate_certs.sh
	docker compose -f srcs/docker-compose.yml build

up:
	rm -rf /home/manuel/data/*
	chmod +x ./srcs/requirements/tools/generate_certs.sh
	./srcs/requirements/tools/generate_certs.sh
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	@echo "Limpiando todos los recursos de Docker no usados y reiniciando el daemon..."
	docker compose -f srcs/docker-compose.yml down -v || true
	docker system prune -a --volumes --force
	systemctl restart docker
	@echo "Esperando a que el daemon de Docker se reinicie..."
	sleep 8 # Pequeña pausa para asegurar que el daemon se ha reiniciado completamente

.PHONY: all build up down clean
