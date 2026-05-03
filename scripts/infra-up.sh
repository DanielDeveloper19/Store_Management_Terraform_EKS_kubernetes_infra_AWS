#!/bin/bash
set -e # Exit immediately if a command fails

# --- 0. Tooling Check (kubectl) ---
if ! command -v kubectl &> /dev/null; then
    echo "pkg: kubectl not found. Installing..."
    # Download the latest stable release for Linux amd64
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    echo "✅ kubectl installed successfully."
else
    echo "✔ kubectl is already installed."
fi


# Move to the terraform directory relative to the script location
cd "$(dirname "$0")/../terraform"

# --- 1. Infrastructure Provisioning ---
echo "🚀 Starting Terraform Apply..."
terraform init 
terraform apply -auto-approve -parallelism=20

# --- 2. Kubernetes Context Setup ---
echo "🔗 Connecting to EKS Cluster..."
# We extract the cluster name and region from Terraform outputs to avoid hardcoding
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw region)

aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# --- 3. Argo CD Installation ---
echo "🛠️ Installing Argo CD..."
# 1. Ensure the namespace exists first
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# 2. Install Argo CD using Server-Side apply to handle the large CRDs
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Wait for Argo CD server to be ready

echo "⏳ Waiting for Argo CD to start..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# --- 4. Deploying the GitOps Application ---
echo "📦 Creating the Argo CD Application..."
# This points Argo CD to your MANIFEST repository
kubectl apply -f ../ArgoCd/helm-application.yaml

echo "✅ Environment is UP! Access your API via the LoadBalancer URL."
