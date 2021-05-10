.DEFAULT_GOAL := help
.SILENT:

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)
DB     := "/var/media/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db"

## Starts the containers
start:
	docker-compose up -d --remove-orphans

## Stops the containers
stop:
	docker-compose down

## Stops the containers, updates the images and then starts the containers again
update:
	docker-compose pull
	docker-compose restart
	docker image prune -a -f

## Cleanup the names of episodes
cleanup:
	$(MAKE) stop
	cp -f "${DB}" "${DB}.backup"
	sqlite3 "${DB}" "DROP index 'index_title_sort_naturalsort'"
	sqlite3 "${DB}" "DELETE from schema_migrations where version='20180501000000'"
	sqlite3 "${DB}" "UPDATE metadata_items SET title = replace(title, '(1)', '(Part 1)'), title_sort = replace(title_sort, '(1)', '(Part 1)') WHERE metadata_type = 4;"
	sqlite3 "${DB}" "UPDATE metadata_items SET title = replace(title, '(2)', '(Part 2)'), title_sort = replace(title_sort, '(2)', '(Part 2)') WHERE metadata_type = 4;"
	sqlite3 "${DB}" "UPDATE metadata_items SET title = replace(title, '(3)', '(Part 3)'), title_sort = replace(title_sort, '(3)', '(Part 3)') WHERE metadata_type = 4;"
	$(MAKE) start

## Backup the data to the NAS
backup:
	rsync -ravz --delete --exclude="plex/" /var/media/ /media/Backup/rpi/
	# rsync -ravz --delete /var/lib/homebridge/ /media/Backup/homebridge/
	tar -vcz --exclude="./Cache" -f /tmp/plex-backup.tar.gz /var/media/plex
	cp /tmp/plex-backup.tar.gz /media/Backup/
	rm -f /tmp/plex-backup.tar.gz

## Prints this help
help:
	@echo "\nUsage: make ${YELLOW}<target>${RESET}\n\nThe following targets are available:\n";
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)
