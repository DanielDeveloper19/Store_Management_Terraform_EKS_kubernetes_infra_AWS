#!/bin/bash

set -e

# Move to the terraform directory
cd "$(dirname "$0")/../terraform"


echo "⚠️ Starting Full Environment Destruction..."

# --- 1. Clean up Kubernetes Resources ---
# Deleting the Argo app and Helm releases first ensures AWS Load Balancers are deleted
echo "🧹 Cleaning up Kubernetes LoadBalancers and Apps..."
kubectl delete -f ./argocd/application.yaml --ignore-not-found
kubectl delete namespace argocd --ignore-not-found

# Wait a moment for AWS to detect the Load Balancer deletions
echo "⏳ Waiting for Cloud Provider cleanup..."
sleep 60 

# --- 2. Infrastructure Destruction ---
echo "💣 Destroying AWS Resources via Terraform..."
terraform destroy -auto-approve

echo "✨ Environment fully wiped."
