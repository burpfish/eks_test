#!/usr/bin/env sh

# Clean up (assumes the workspace has expired - i.e. we don't call tf destroy)
rm token.txt -f
rm terraform.tfstate -f
rm cluster_autoscaler.yml -f
rm test_service.yml -f