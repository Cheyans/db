#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <test_rev>"
  echo "    <test_rev>  The previous DB revision to test against"
  echo
  echo "Example: $0 \$(git rev-parse HEAD)"
  exit 1
fi

db=faf_test
pw=banana
previousRev=$1
docker_container=faf-db

docker exec -i faf-db mysql -p${pw} -e "drop database ${db}; create database ${db}" \
&& git cat-file -p ${previousRev}:db-structure.sql | docker exec -i ${docker_container} mysql -p${pw} ${db} \
&& git cat-file -p ${previousRev}:db-data.sql | docker exec -i ${docker_container} mysql -p${pw} ${db} \
&& for file in `find -name "*${previousRev}.sql"`; do docker exec -i ${docker_container} mysql -p${pw} ${db} < "$file"; done \
&& docker exec -i ${docker_container} mysql -p${pw} ${db} < db-data.sql

exit $?