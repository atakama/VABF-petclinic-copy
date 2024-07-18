.DEFAULT_GOAL := help

VABF_VERSION ?= 1.2
PETCLINIC_VERSION ?= 3.3.0
JAVA_VERSION ?= 17

.PHONY: help
help: ## Display this help
	@echo "Usage:"
	@echo "  make [command] [OPTIONS...]"
	@echo
	@echo "Commands:"
	@echo "  up                    Launch Petclinic with the default configuration (Java 17, H2)"
	@echo "  up-java8              Launch Petclinic with Java 8 and H2"
	@echo "  up-postgres           Launch Petclinic with Java 17 and PostgreSQL"
	@echo "  up-java8-postgres     Launch Petclinic with Java 8 and PostgreSQL"
	@echo
	@echo "Options:"
	@echo "  VABF_VERSION          Specify the VABF version (default: 1.2)"
	@echo "  PETCLINIC_VERSION     Specify the Petclinic version (default: 3.3.0)"
	@echo "  JAVA_VERSION          Specify the Java version (default: 17)"


# Java Latest

.PHONY: up
up: ## Launch Petclinic with the default configuration (Java 17, H2)
	DB_PROFILE=h2 docker compose up -d --build

.PHONY: up-postgres
up-postgres: ## Launch Petclinic with Java 17 and PostgreSQL
	DB_PROFILE=postgres docker compose --profile postgres up -d --build

.PHONY: up-mysql
up-mysql: ## Launch Petclinic with Java 17 and MySQL
	DB_PROFILE=mysql docker compose --profile mysql up -d --build


# Java 8

.PHONY: up-java8
up-java8: ## Launch Petclinic with Java 8 and H2
	DB_PROFILE=h2 JAVA_VERSION=8 docker compose --profile java8 up -d --build

.PHONY: up-java8-postgres
up-java8-postgres: ## Launch Petclinic with Java 8 and PostgreSQL
	DB_PROFILE=postgres JAVA_VERSION=8 docker compose --profile java8 --profile postgres up -d --build

.PHONY: up-java8-mysql
up-java8-mysql: ## Launch Petclinic with Java 8 and MySQL
	DB_PROFILE=mysql JAVA_VERSION=8 docker compose --profile java8 --profile mysql up -d --build


# All

.PHONY: down
down: ## Launch Petclinic with Java 8 and PostgreSQL
	docker compose --profile '*' down
