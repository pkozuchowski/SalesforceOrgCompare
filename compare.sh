#!/bin/bash

source ./utils.sh

# Prepare clean working directories
prepareFolders "$@"

# Retrieve metadata from orgs
retrieveMetadata "$@"

# Retrieve data from queries
queryData "$@"

# Create GIT repository for comparison
createComparisonRepository "$@"