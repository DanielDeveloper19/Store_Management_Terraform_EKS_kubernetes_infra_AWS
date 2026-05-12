Alive Systems: Enterprise-Scale GitOps Platform
A Production-Grade, Self-Healing AWS Ecosystem for Java Microservices.

<img width="1280" height="698" alt="1776915153087" src="https://github.com/user-attachments/assets/8677430e-296c-4368-8194-2b09edf9e0a0" />
<img width="1408" height="768" alt="Gemini_Generated_Image_eqn1h6eqn1h6eqn1" src="https://github.com/user-attachments/assets/8b30d1c7-62ca-4522-9e54-28cf7d6045ad" />
<img width="1408" height="768" alt="Gemini_Generated_Image_vcd3b1vcd3b1vcd3" src="https://github.com/user-attachments/assets/2a883864-b132-4082-bb12-7103ed9163d3" />

# ⛅ Alive Systems: Cloud Engine
> **Enterprise-Scale Infrastructure-as-Code & GitOps Orchestration.**

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)

### 🎯 The Vision
This project is a technical showcase of the **"Conqueror Mindset"** in software engineering—transforming manual infrastructure complexity into a single, automated, and observable system. It provides a **"One-Click"** solution to deploy a highly available, secure, and production-ready environment on AWS using industry-standard GitOps principles.

---

## ⚡ The One-Click Command Center
The entire platform—from the VPC networking to the live application—is provisioned using a single orchestration script. This eliminates manual error and reduces environment setup time from **4 hours to 20 minutes.**

### 🛠️ Quick Start
To deploy the ecosystem, you will need to fork the supporting repositories first:
* **Java Source Code:** [store_management](https://github.com/DanielDeveloper19/store_management.git)
* **Manifests Repo:** [Store_Management_KubernetesManifests](https://github.com/DanielDeveloper19/Store_Management_KubernetesManifests.git)

#### 💻 Local Setup & Execution
1.  **Clone this Engine:**
    ```bash
    git clone [https://github.com/DanielDeveloper19/Store_Management_Terraform_EKS_kubernetes_infra_AWS.git](https://github.com/DanielDeveloper19/Store_Management_Terraform_EKS_kubernetes_infra_AWS.git)
    ```
2.  **Initialize Environment:**
    * Install **Terraform** and configure your **AWS CLI** (`aws configure`).
    * Update variables in `infra-up.sh` to point to your forked repositories.
3.  **Execute the Engine:**
    ```bash
    chmod +x scripts/infra-up.sh
    ./scripts/infra-up.sh
    ```

---

## 🕵️‍♀️ What happens behind the scenes?
1.  **Infrastructure Provisioning:** Terraform initializes and provisions a multi-AZ VPC, EKS Cluster, and RDS instance.
2.  **Context Synchronization:** The `kubectl` context is automatically updated with cluster credentials.
3.  **Ingress Management:** The **AWS Load Balancer Controller** is installed to manage external traffic.
4.  **GitOps Initialization:** **ArgoCD** is deployed and configured to "pull" the latest manifests, bringing the Java Spring Boot application to life.

---

## 🏗️ Core Architectural Pillars

### 🔒 Resilient Infrastructure-as-Code (Terraform)
* **Multi-AZ VPC:** Spans across **3 AWS Availability Zones** for high availability.
* **Network Isolation:** Public subnets house the ALB and NAT Gateways; **EKS Nodes and RDS reside in Private Subnets**, unreachable from the public internet.
* **Compute:** Managed Amazon EKS cluster using `t3.medium` node groups for an optimal balance of memory and performance.

### 🐙 Zero-Touch GitOps (ArgoCD & Helm)
* **Pull-Based Deployment:** ArgoCD continuously monitors the Manifests Repo for changes.
* **Self-Healing:** Manual cluster changes are automatically reconciled back to the Git source of truth.
* **Automated Sync:** Integrated synchronization policy deploys new versions immediately upon Git push.

### 🛡️ Shift-Left Security & Observability
* **Database Security:** MySQL RDS is protected by strict Security Groups, allowing traffic **only** from EKS nodes on port 3306.
* **Quality Gates:** The CI pipeline includes **Trivy** vulnerability scans and **SonarQube** analysis.
* **Full-Stack Telemetry:** Integrated **Prometheus and Grafana** provide 24/7 health monitoring for all cluster components.

---

## 🧠 Engineering Decisions & Trade-offs
> **Senior Insight:** "The best architecture isn't the most complex; it's the one that balances reliability with cost and maintainability."

* **AWS EKS vs. EC2:** Chosen to leverage managed control planes and auto-scaling, allowing focus on application logic over server maintenance.
* **db.t4g.micro:** Selected for **Graviton2 performance efficiency**, providing 20% better price-performance than Intel-based instances.
* **NAT Gateways:** Implemented to allow private pods (EKS/RDS) outbound updates while blocking all inbound threats.

---

## 🤖 Project Ecosystem Table

| Component | Responsibility | Repository Link |
| :--- | :--- | :--- |
| **⛅ Cloud Engine** | Terraform, VPC, EKS, RDS | [Infrastructure Repo](https://github.com/DanielDeveloper19/Store_Management_Terraform_EKS_kubernetes_infra_AWS.git) |
| **💻 Business Logic** | Java Spring Boot Application | [Source Code Repo](https://github.com/DanielDeveloper19/store_management.git) |
| **⚓ GitOps State** | Helm Charts & K8s Manifests | [Manifests Repo](https://github.com/DanielDeveloper19/Store_Management_KubernetesManifests.git) |

---
*Built by Daniel Montoya — Alive Systems Lab.*
