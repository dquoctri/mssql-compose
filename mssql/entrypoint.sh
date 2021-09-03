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
