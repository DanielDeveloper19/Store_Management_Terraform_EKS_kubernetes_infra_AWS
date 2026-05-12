#!/bin/bash
set -e # Exit immediately if a command fails

# This script sets up monitoring for an EKS cluster using Prometheus and Grafana.
echo "Setting up monitoring for EKS cluster using Prometheus and Grafana"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Creating monitoring namespace"
kubectl create namespace monitoring

echo "Installing kube-prometheus-stack"
helm install my-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.enabled=true

