#!/bin/bash
set -e # Exit immediately if a command fails

echo "Install eksctl if not already installed"
if ! command -v eksctl &> /dev/null; then
    echo "eksctl no encontrado. Iniciando instalación..."
    
    # Corrected URL: added the repo path and fixed the $(uname -s) syntax
    # We use 'latest/download' to ensure we get the binary directly
    PLATFORM=$(uname -s)_amd64
    URL="https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    
    echo "Descargando desde: $URL"
    
    # Added -f to curl so it fails if the URL is 404, preventing tar from running on empty input
    curl --silent --location --fail "$URL" | tar xz -C /tmp
    
    # Verificar si la descompresión fue exitosa
    if [ $? -eq 0 ]; then
        sudo mv /tmp/eksctl /usr/local/bin
        echo "Instalación de eksctl completada exitosamente."
    else
        echo "Error: Falló la descarga. Esto suele pasar si la URL es incorrecta o no hay internet."
        exit 1
    fi
else
    echo "eksctl ya está instalado, saltando este paso."
fi




echo "Step 1: Create an IAM OIDC Provider for your EKS cluster"
eksctl utils associate-iam-oidc-provider \
    --cluster "$CLUSTER_NAME" \
    --region "$REGION" \
    --approve



echo "Step 2: Check or Update the IAM Policy"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

# 1. URL CORRECTA (Directa al archivo JSON raw)
POLICY_URL="https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

curl -s -o iam_policy.json "$POLICY_URL"

# Validar que el archivo se descargó correctamente
if [ ! -s iam_policy.json ]; then
    echo "Error: No se pudo descargar el archivo de política de GitHub (URL inválida o sin internet)."
    exit 1
fi

# 2. Verificar si la política ya existe
if aws iam get-policy --policy-arn "$POLICY_ARN" > /dev/null 2>&1; then
    echo "La política ya existe en tu cuenta AWS."
    
    # OPCIÓN: Aquí podrías simplemente decir "Saltando actualización" para evitar el límite de 5 versiones
    echo "Skipping update to avoid IAM version limits (max 5)."
else
    echo "Creando nueva política..."
    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document file://iam_policy.json
fi


echo "Step 3: Create the IAM Role for the Service Account"
eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --region="$REGION" \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve



echo "Step 4: Install the Controller via Helm"
helm repo add eks https://aws.github.io/eks-charts
helm repo update

echo "Step 5: Install or Upgrade the AWS Load Balancer Controller"
# It is highly recommended to explicitly set the VPC and Region on EKS
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$AWS_REGION" \
  --set vpcId="$VPC_ID"

echo "Step 6: Wait for the controller to be ready"
# This prevents the "no endpoints" race condition
kubectl wait --namespace kube-system \
  --for=condition=available deployment/aws-load-balancer-controller \
  --timeout=120s