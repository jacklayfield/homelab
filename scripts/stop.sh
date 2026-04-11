#!/bin/bash

echo "Stopping homelab services..."
docker compose -f docker/docker-compose.yml down