USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)

.PHONY: build start stop restart term logs

build:
	docker-compose build


start:
	@echo "start docker as ${USER_ID}:${GROUP_ID}"
	export USER_ID=$(USER_ID) 
	export GROUP_ID=$(GROUP_ID) 
	docker-compose up -d 


stop:
	docker-compose down

term:
	docker-compose exec openconnect /bin/bash


logs:
	docker-compose logs openconnect


copy_ssh_key:
	docker-compose exec openconnect cat /home/docker/.ssh/id_rsa.pub > id_rsa_docker
	chmod 600 id_rsa_docker

