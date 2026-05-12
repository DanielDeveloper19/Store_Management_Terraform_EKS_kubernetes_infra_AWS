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

# 1. Save the path to 'scripts/' before changing directories, so we can use it later for the load balancer installation
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

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

aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME


# Create the DB Secret in K8s
echo "🔐 Creating Kubernetes Secret for RDS credentials..."
  #create namespace for the deployment of java app and these RDS secret
kubectl create namespace store-management

kubectl create secret generic rds-db-credentials \
  --from-literal=url="jdbc:mysql://${DB_URL}/store_management" \
  --from-literal=username=$DB_USER \
  --from-literal=password=$DB_PASS \
  -n store-management --dry-run=client -o yaml | kubectl apply -f -


# --- 3. AWS Load Balancer Controller Installation ---
echo "🛠️ Installing AWS Load Balancer Controller..."

# Get your AWS Account ID automatically
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export CLUSTER_NAME
export REGION
# Llamas al instalador usando la ruta que guardaste al inicio
"$SCRIPT_DIR/load_balacer/install_aws_load_balacer.sh"





# --- 4. Argo CD Installation ---
echo "🛠️ Installing Argo CD..."
# 1. Ensure the namespace exists first
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "Install Argo CD using Server-Side apply to handle the large CRDs"
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Wait for Argo CD server to be ready

echo "⏳ Waiting for Argo CD to start..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# --- 4. Deploying the GitOps Application ---
echo "📦 Creating the Argo CD Application..."
# This points Argo CD to your MANIFEST repository
kubectl apply -f ../ArgoCd/helm-application.yaml

echo "Installing monitoring stack (Prometheus + Grafana)..."
"$SCRIPT_DIR/monitoring/create_monitoring.sh"

echo "✅ Environment is UP! Access your API via the LoadBalancer URL."
