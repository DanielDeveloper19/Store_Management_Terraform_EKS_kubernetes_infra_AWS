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
- Fork these two Github repositories, are the Java source code and the manifests Repo:
  https://github.com/DanielDeveloper19/store_management.git
  https://github.com/DanielDeveloper19/Store_Management_KubernetesManifests.git

🛠️ In your local machine:
- Clone the Infrastructure repository:
  git clone https://github.com/DanielDeveloper19/Store_Management_Terraform_EKS_kubernetes_infra_AWS.git

- Configure AWS Credentials: aws configure
  install Terraform
- There are a couple of variables you need to modify in the scripts you cloned; for example, changing a variable to point to the manifest repository you forked, or in the CI pipeline in the Java source code, all of that is really straightforward.
- Execute the Engine:
  Bash
chmod +x scripts/infra-up.sh
./scripts/infra-up.sh
-----------------------------------
🕵️‍♀️What happens behind the scenes?

Terraform initializes and provisions the multi-AZ network and EKS cluster in your AWS account.

kubectl context is automatically updated with cluster credentials.

AWS Load Balancer Controller is installed to manage external traffic.

ArgoCD is deployed and configured to "pull" the latest manifests from Git.
Now you have your Java application deployed in a production grade AWS Ecosystem with EKS Kubernetes and GitOps workflow.

----------------------

🏗️ Core Architectural Pillars
1. Resilient Infrastructure-as-Code (Terraform)
Multi-AZ VPC: Spans across 3 Availability Zones for high availability.

Network Isolation: Public subnets house the ALB and NAT Gateways, while EKS Nodes and RDS reside in Private Subnets , unreachable from the public internet.

Compute: Managed Amazon EKS cluster using t3.medium node groups for an optimal balance of memory, performance and cost.

2. Zero-Touch GitOps (ArgoCD & Helm)
Pull-Based Deployment: ArgoCD continuously monitors the [Manifests Repo] for changes.

Self-Healing: If manual changes are made to the cluster, ArgoCD automatically reconciles the state back to the Git source of truth.

Automated Sync: Integrated synchronization policy that deploys new versions as soon as they are pushed to Git.

3. Shift-Left Security & Networking
Database Security: MySQL RDS is protected by strict Security Groups, allowing traffic only from the EKS nodes on port 3306.

Image Scanning: The CI pipeline includes Trivy vulnerability scans and SonarQube, automated tests and code quality gates before images reach the registry.

------------------

🧠 Engineering Decisions & Trade-offs
Why AWS EKS over EC2? To leverage managed control plans and auto-scaling capabilities, allowing the team to focus on application logic rather than server maintenance.

Why db.t4g.micro? Chosen for its Graviton2 performance efficiency. It provides 20% better price-performance than Intel-based instances for our development workloads.

Why NAT Gateways? To allow private pods (EKS/RDS) to perform outbound updates while remaining protected from inbound threats.

------------

🤖Project Ecosystem Table:

⛅Cloud Engine(Terraform, VPC, EKS, RDS): https://github.com/DanielDeveloper19/Store_Management_Terraform_EKS_kubernetes_infra_AWS.git
💻Business Logic(Java Spring Boot Application):https://github.com/DanielDeveloper19/store_management.git
GitOps State(Helm Charts & Kubernetes Manifests): https://github.com/DanielDeveloper19/Store_Management_KubernetesManifests.git


