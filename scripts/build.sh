#!/bin/sh
set -e

base_dir=$(pwd)

cd petclinic
	echo "Build de petclinic"
	./mvnw package
fi
cd ${base_dir}
