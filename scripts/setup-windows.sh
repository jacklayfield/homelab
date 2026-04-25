#!/bin/bash

echo "Checking Docker..."

if ! command -v docker &> /dev/null
then
    echo "Docker not installed. Please install Docker Desktop."
    exit 1
fi

echo "Docker is available!"