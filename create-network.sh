#!/bin/bash

NETWORK_NAME="media-network"

if docker network inspect $NETWORK_NAME >/dev/null 2>&1; then
  echo "Network $NETWORK_NAME already exists."
else
  docker network create $NETWORK_NAME
  echo "Network $NETWORK_NAME created."
fi