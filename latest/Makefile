# Raccourcis autour de docker-bake.hcl. Tout le detail du build y vit.
VERSION ?= dev
ITSMNG_PLUGINS ?=

export VERSION
export ITSMNG_PLUGINS

.PHONY: build release lint up down logs shell clean

## Construit l'image pour la plateforme locale et la charge dans le daemon.
build:
	docker buildx bake --load itsmng

## Construit multi-arch avec attestations et pousse.
release:
	docker buildx bake --push release

## Analyse statique du Dockerfile et des scripts.
lint:
	docker run --rm -i hadolint/hadolint < Dockerfile
	docker run --rm -v "$(CURDIR):/mnt" -w /mnt koalaman/shellcheck:stable \
		--severity=warning \
		rootfs/usr/local/bin/itsmng-init \
		rootfs/usr/local/bin/itsmng-cron \
		rootfs/usr/local/bin/itsmng-console

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f itsmng

## Shell dans le conteneur web (utilisateur non privilegie).
shell:
	docker compose exec itsmng bash

clean:
	docker compose down -v
