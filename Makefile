include .env

stop_containers:
	@echo "stop other docker containers";
	if [ $$(sudo docker ps -q) ]; then \
		echo "Found and stopped containers"; \
		sudo docker stop $$(sudo docker ps -q); \
	else \
		echo "no containers running"; \
	fi

create_container:
	sudo docker run --name ${DB_DOCKER_CONTAINER} -p 5432:5432 -e POSTGRES_USER=${USER} -e POSTGRES_PASSWORD=${PASS} -d postgres:latest

create_db:
	sudo docker exec -it ${DB_DOCKER_CONTAINER} createdb --username=${USER} --owner=${USER} ${DB_NAME}

start_container:
	sudo docker start ${DB_DOCKER_CONTAINER}

create_migrations:
	sqlx migrate add -r init

migrate_up:
	sqlx migrate run --database-url "postgres://${USER}:${PASS}@${HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable"

migrate_down:
	sqlx migrate revert --database-url "postgres://${USER}:${PASS}@${HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable"

build:
	if [ -f "${BINARY}" ]; then \
		rm ${BINARY}; \
		echo "Deleted ${BINARY}"; \
	fi
	@echo "Building binary..."
	go build -o ${BINARY} cmd/server/*.go

run: build
	./${BINARY}

stop:
	@echo "stopping server..."
	@-pkill -SIGTERM -f "./${BINARY}"
	@echo "server stopped..."
