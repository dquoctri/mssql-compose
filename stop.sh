#!/bin/bash

docker compose down;

read -n 1 -s -r -p "Press any key except 'power off' to continue!"
exit 0;
