Alive Systems: Enterprise-Scale GitOps Platform
A Production-Grade, Self-Healing AWS Ecosystem for Java Microservices.

<img width="1280" height="698" alt="1776915153087" src="https://github.com/user-attachments/assets/8677430e-296c-4368-8194-2b09edf9e0a0" />
<img width="1408" height="768" alt="Gemini_Generated_Image_eqn1h6eqn1h6eqn1" src="https://github.com/user-attachments/assets/8b30d1c7-62ca-4522-9e54-28cf7d6045ad" />
<img width="1408" height="768" alt="Gemini_Generated_Image_vcd3b1vcd3b1vcd3" src="https://github.com/user-attachments/assets/2a883864-b132-4082-bb12-7103ed9163d3" />

🎯 The Vision
This project is a technical showcase of the "Conqueror Mindset" in software engineering—transforming manual infrastructure complexity into a single, automated, and observable system. It provides a "One-Click" solution to deploy a highly available, secure, and production-ready environment on AWS using industry-standard GitOps principles.

------------------------------------
⚡The One-Click Command Center
The entire platform—from the VPC networking to the live application—is provisioned using a single orchestration script. This eliminates manual error and reduces environment setup time from 4 hours to 20 minutes.

🛠️ Quick Start
Clone the repository: git clone https://github.com/DanielDeveloper19/Store_Management_Terraform_EKS_kubernetes_infra_AWS.git

Configure AWS Credentials: aws configure

Execute the Engine:
Bash
chmod +x scripts/infra-up.sh
./scripts/infra-up.sh
-----------------------------------
What happens behind the scenes?

Terraform initializes and provisions the multi-AZ network and EKS cluster.

kubectl context is automatically updated with cluster credentials.

AWS Load Balancer Controller is installed to manage external traffic.

ArgoCD is deployed and configured to "pull" the latest manifests from Git.
