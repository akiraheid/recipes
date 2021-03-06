pack ::= "recipe-image.tgz"
src ::= "~/recipes"
pwd ::= $(shell pwd)

build: Dockerfile build-dist
	docker build -t recipes .

build-dist: node_modules
	npx webpack
	cp -r src/public/css/* dist/
	cp node_modules/bootstrap/dist/css/bootstrap.min.css dist/

clean:
	-rm -rf ${pack} *.log dist nightwatch_output node_modules

deploy: clean build package upload server-restart

lint:
	docker run --rm -v ${pwd}:/data:ro cytopia/eslint .

node_modules: package.json
	npm install

package:
	docker save -o ${pack} recipes

serve: build
	cp -n .env.example .env
	docker-compose up -d

serve-down:
	docker-compose down

serve-log:
	-docker-compose logs -f

server-restart:
	ssh recipes "cd ${src} && docker-compose up -d"

test: lint node_modules build serve
	npm test

upload: package
	-ssh recipes "cd ${src} && rm -r *"
	rsync -vc --progress ${pack} recipes:${src}
	rsync -vc --progress docker-compose.yml recipes:${src}
	ssh recipes "cd ${src} && docker load -i ${pack} && rm ${pack}"

.PHONY: build build-dist clean deploy package serve serve-down serve-log server-restart test upload
