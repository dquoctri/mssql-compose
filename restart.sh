#!/bin/bash

docker compose down;

# docker volume rm -f mssql-compose_mssqlsystem mssql-compose_mssqluser;

docker compose build --no-cache;

# docker compose --env-file ./demo.env up -d;
docker compose up -d;

read -n 1 -s -r -p "Press any key except 'power off' to continue!"
exit 0;
