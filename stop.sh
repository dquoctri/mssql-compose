#!/bin/bash

docker compose down;

read -n 1 -s -r -p "Press any key without 'power off' to continue!"
exit 0;
