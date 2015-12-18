#!/bin/bash

# Make entire repo available in the build context
# but use the Dockerfile in this directory
docker build --file="./Dockerfile" $@ ../..