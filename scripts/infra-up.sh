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
# We extract the cluster name and region AND database credentials from Terraform outputs to avoid hardcoding
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw region)
DB_URL=$(terraform output -raw db_endpoint)
DB_USER=$(terraform output -raw db_username)
DB_PASS=$(terraform output -raw db_password)

# Create the DB Secret in K8s
kubectl create secret generic rds-db-credentials \
  --from-literal=url="jdbc:mysql://${DB_URL}:3306/store_management" \
  --from-literal=username=$DB_USER \
  --from-literal=password=$DB_PASS \
  -n store-management --dry-run=client -o yaml | kubectl apply -f -

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
