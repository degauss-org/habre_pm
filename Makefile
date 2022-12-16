.PHONY: build test shell clean

build:
	docker build -t habre_pm .

test:
	docker run --rm -v "${PWD}/test":/tmp habre_pm my_address_file_geocoded.csv

shell:
	docker run --rm -it --entrypoint=/bin/bash -v "${PWD}/test":/tmp habre_pm

clean:
	docker system prune -f