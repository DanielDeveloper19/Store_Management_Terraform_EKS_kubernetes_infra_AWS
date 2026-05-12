#!/bin/bash
# cleanup-eks-pro.sh

# Move to the terraform directory relative to the script location
cd "$(dirname "$0")/../terraform"

echo "Initiating Alive Systems Deep Cleanup..."

# 1. DELETE ARGO APPS (If using Argo CD)
# This prevents Argo from "fighting" the deletion by re-syncing resources.
if kubectl get crd applications.argoproj.io &> /dev/null; then
    echo "Detected Argo CD. Deleting Applications..."
    kubectl delete apps --all -n argocd --timeout=60s
fi

# 2. CLEAR LOAD BALANCERS & SERVICES
echo "Deleting Ingresses and LoadBalancer Services..."
kubectl delete ingress --all --all-namespaces --timeout=60s
kubectl delete svc --all --all-namespaces -l "service.beta.kubernetes.io/aws-load-balancer-type"

# 3. THE VERIFICATION LOOP (Replaces the 'blind' sleep)
# We wait until the ALB is actually gone from the AWS side.
echo "Waiting for AWS to release Network Interfaces (ENIs)..."
for i in {1..12}; do
    # Check if any ALBs are still active
    ALB_COUNT=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text | wc -w)
    if [ "$ALB_COUNT" -eq "0" ]; then
        echo "AWS resources cleared. Proceeding..."
        break
    fi
    echo "ALB still exists... waiting 15s (Attempt $i/12)"
    sleep 15
done

# 4. FINAL TERRAFORM DESTROY
echo "Starting Terraform Destroy..."
terraform destroy -auto-approve