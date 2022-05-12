# mssql-compose
MSSQL (Microsoft SQL Server) powered by docker-compose. This GitHub repository contains code samples that demonstrate how to use Microsoft SQL Server on docker using docker-compose. This explains how to run and use the sample. To make this repo reusable just keep it small. This is helpful for all applications which using the MSSQL database. There is an overview of the technologies used.

# [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
> Developed by Microsoft, SQL Server is one of the most popular relational database technologies in the world. Its primary function is to store and retrieve data quested by other applications. SQL Server is commonly used in applications that support transactional and analytical workloads.

# [Docker](https://docs.docker.com/get-started/overview)
> Docker is an open platform for developing, shipping, and running applications. Docker enables you to separate your applications from your infrastructure so you can deliver software quickly. With Docker, you can manage your infrastructure in the same ways you manage your applications. By taking advantage of Docker’s methodologies for shipping, testing, and deploying code quickly, you can significantly reduce the delay between writing code and running it in production.

# [Docker Compose](https://docs.docker.com/compose/)
> Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application’s services. Then, with a single command, you create and start all the services from your configuration.

# Prerequisities
## Docker and docker-compos
Docker and docker-compose are required in order to run this app successfully
* docker >= 19.03.0+
* docker-compose

You can download and install Docker on multiple platforms. Refer to the [following section](https://docs.docker.com/get-docker/) and choose the best installation path for you.

Check the version of docker to make sure docker is installed

```
docker --version
```
> Docker version 20.10.7, build f0df350

## Microsoft SQL Server
* This image requires Docker Engine 1.8+ in any of their supported platforms.

* At least 2GB of RAM (3.25 GB prior to 2017-CU2). Make sure to assign enough memory to the Docker VM if you're running on Docker for Mac or Windows.

* Requires the following environment flags

  "ACCEPT_EULA=Y"

  "SA_PASSWORD=

  "MSSQL_PID=<your_product_id | edition_name> (default: Developer)"

* A strong system administrator (SA) password: At least 8 characters including uppercase, lowercase letters, base-10 digits and/or non-alphanumeric symbols.


# Quick Start

Clone this repository first:

```
git clone https://github.com/dquoctri/mssql-compose.git
cd mssql-compose
```
The following commands need to be run docker compose:

```
docker compose up -d
```
# Details
## Code structure

Here’s a documentation project structure

![image](https://user-images.githubusercontent.com/87698179/133193820-26c6c416-f449-4d5f-a48b-74d08882f5d0.png)

## docker-compose.yml

```
version: '3.9'

services:
  mssql_db:
    container_name: mssql_container
    image: ${MSSQL_IMAGE:-mcr.microsoft.com/mssql/server:latest}
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_PID: ${MSSQL_PRODUCT_ID:-Developer}
      SA_PASSWORD: "${MSSQL_SA_PASSWORD:-StrongP@ssword}"
    volumes:
      - mssqlsystem:/var/opt/mssql
      - mssqluser:/var/opt/sqlserver
      - ${MSSQL_CONFIG_DIR:-./config/mssql}/entrypoint.sh:/usr/src/app/entrypoint.sh
      - ${MSSQL_CONFIG_DIR:-./config/mssql}/sql/:/usr/src/app/docker-entrypoint-initdb.d
    working_dir: /usr/src/app
    command: sh -c ' chmod +x ./entrypoint.sh; ./entrypoint.sh & /opt/mssql/bin/sqlservr;'
    ports:
      - "${MSSQL_PORT:-1433}:1433"
    networks:
      - env_net
    restart: unless-stopped

networks:
  env_net:
    external: true
    driver: bridge

volumes:
  mssqlsystem: # external: true
  mssqluser: # external: true
  
```

## Note
> Both **$VARIABLE** and **${VARIABLE}** syntax are supported. Additionally when using the 2.1 file format, it is possible to provide inline default values using typical shell syntax:
> 
> - **${VARIABLE:-default}** evaluates to `default` if `VARIABLE` is unset or empty in the environment.
> - **${VARIABLE-default}** evaluates to `default` only if `VARIABLE` is unset in the environment.
> 
> Similarly, the following syntax allows you to specify mandatory variables:
> 
> - **${VARIABLE:?err}** exits with an error message containing `err` if `VARIABLE` is unset or empty in the environment.
> - **${VARIABLE?err}** exits with an error message containing `err` if `VARIABLE` is unset in the environment.
> 
> Other extended shell-style features, such as **${VARIABLE/foo/bar}**, are not supported.
> 
> You can use a `$$` (double-dollar sign) when your configuration needs a literal dollar sign. This also prevents Compose from interpolating a value, so a `$$` allows you to refer > to environment variables that you don’t want processed by Compose.

## Environments

Set environment variables used by the system in ./*.env file (Copy the sample in `demo.env` file, example: `dev.env`, `prod.env` and `.env` by default) with specific version of [Microsoft SQL Server](https://hub.docker.com/_/microsoft-mssql-server) images. 


```
MSSQL_CONFIG_DIR='./.config/mssql'
MSSQL_VERSION=2019-CU12-ubuntu-20.04
#MSSQL_PRODUCT_ID=Express
MSSQL_PRODUCT_ID=Developer
MSSQL_SA_PASSWORD=StrongP@ssword
MSSQL_PORT=1433

```

Create a expected config for the environment follow by demo config structure and update 2 environment variables below: 
```
MSSQL_CONFIG_DIR='<postgres_config_dir>' (./dev.config/mssql, ./prod.config/mssql and ./.config/mssql by default)
...
```
by defualt `./.config/mssql`

## Add init SQL scripts in Microsoft SQL Server

The `entrypoint.sh` script will load all `*.sql` files to execute. copy file in your own config.

```
#!/bin/bash
waiting_time=60

# wait for MSSQL server to start
export STATUS=1
i=0

sleep $waiting_time/2
while [[ $STATUS -ne 0 ]] && [[ $i -lt $waiting_time/2 ]];
do
	i=$i+1
	/opt/mssql-tools/bin/sqlcmd -t 1 -U sa -P $SA_PASSWORD -Q "select 1" >> /dev/null
	STATUS=$?
done

if [ $STATUS -ne 0 ]; then 
	echo "======= Error: MSSQL SERVER took more than $waiting_time seconds to start up.  ========";
	exit 1
fi

echo "======= MSSQL SERVER STARTED ========"
# Run the setup scripts by add one or more *.sql in docker-entrypoint-initdb.d
for filename in ./docker-entrypoint-initdb.d/*.sql; do
	/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i "$filename";
done

echo "======= MSSQL CONFIG COMPLETE ======="
```
Init the volumes and all the scripts in `/usr/src/app/docker-entrypoint-initdb.d` will be executed when creating MSSQL volume by alphabetical order so we should create files with prefix. When you have more init SQL script then you only create new file with `.sql` extention in folder `${MSSQL_CONFIG_DIR:-./config/mssql}/sql/`.

```
  ...
  volumes
      ...
      - ${MSSQL_CONFIG_DIR:-./config/mssql}/entrypoint.sh:/usr/src/app/entrypoint.sh
      - ${MSSQL_CONFIG_DIR:-./config/mssql}/sql/:/usr/src/app/docker-entrypoint-initdb.d
  working_dir: /usr/src/app
  command: sh -c ' chmod +x ./entrypoint.sh; ./entrypoint.sh & /opt/mssql/bin/sqlservr;'
  ...
```
# Manage database
## new connection with Microsoft SQL Server Management Studio:
* **Server name:** `127.0.0.1,1433`
* **Login** as `sa`
* **Password** as `MSSQL_SA_PASSWORD`, by default: `StrongP@ssword`
* 
* **Login** as `MSSQL_USER`, by default: `admin`
* **Password** as `MSSQL_PASSWORD`, by default: `P@ssword`
* 
![image](https://user-images.githubusercontent.com/87698179/133215163-1db19a9f-53ea-448a-b10d-ffdc7cda3b7c.png)


## create a connection in DBeaver:
* **Host name/address** `postgres`
* **Port** as `MSSQL_PORT`, by default: `1433`
* **Database/Schema:** `MSSQL_DB` , by default: `mssql1`
* 
* **Login** as `MSSQL_USER`, by default: `admin`
* **Password** as `MSSQL_PASSWORD`, by default: `P@ssword`
* or * **Login** as `sa` and password `MSSQL_SA_PASSWORD`, by default: `StrongP@ssword`

![image](https://user-images.githubusercontent.com/87698179/133215482-3e66b133-c782-4091-999a-6d06197c79f6.png)

