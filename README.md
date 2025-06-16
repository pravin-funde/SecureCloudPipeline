# 🔐 SecureCloudPipeline

A modern, security-first DevSecOps pipeline that scans, hardens, and securely deploys a containerized Python Flask web application to AWS — all with infrastructure as code.

---

## 🚀 What This Project Covers

✅ Build a secure Docker image  
✅ Automatically scan for vulnerabilities  
✅ Detect secrets, misconfigurations, and insecure code  
✅ Deploy securely to cloud using Terraform

---

## 🛠️ Tools & Stages

| Stage                  | Tool Used      | Purpose                                  |
|------------------------|----------------|------------------------------------------|
| Container Scanning     | **Trivy**       | Scan Docker image for OS & app CVEs      |
| Static Analysis (SAST) | **Semgrep**     | Scan Python source code for bugs/CVEs    |
| IaC Security           | **Checkov**     | Audit Terraform configs for misconfigs   |
| Secrets Detection      | **Gitleaks**    | Detect hardcoded secrets in repo         |
| CI/CD                  | **GitHub Actions** | Automate builds, scans, reporting     |
| Deployment             | **Terraform (AWS)** | Provision secure infrastructure      |

---

## 🐳 Docker Image Hardening

Initial base image (`python:3.10-slim`) had 90+ vulnerabilities (OS + Python packages).

### 🔧 Fixes Applied:
- Switched to Alpine: `python:3.10-alpine` ✅
- Installed only essential system packages
- Removed build dependencies post-install
- Created and used a non-root user for app execution
- Used `--no-cache` and cleaned APT/apk caches

### 📉 Before (Debian-based)
    securecloud-flask (debian 12.11)
    Total: 90 (LOW: 68, MEDIUM: 18, HIGH: 3, CRITICAL: 1) + Python-pacakge vulnerabilities.


### ✅ After (Alpine-based)
    securecloud-flask (alpine) and python package updates
    Total: 0 vulnerabilities 🎉


> All scans are triggered via GitHub Actions on every push.
## 🔐 Security Scan Results (CI Pipeline)
    Results (as of latest commit):

    Tool	Result
    Trivy	✅ 0 vulnerabilities in image & deps
    Semgrep	✅ 0 blocking issues from 1000+ rules

    ✅ Semgrep SAST passed with p/default ruleset — critical rules like host="0.0.0.0" now avoided.
    ---

## ⚙️ Tech Stack

- **Language**: Python (Flask)
- **Containerization**: Docker
- **CI/CD**: GitHub Actions
- **Security**: Trivy, Semgrep, Gitleaks, Checkov
- **Infrastructure as Code**: Terraform
- **Cloud Provider**: AWS (planned)

---

## 📌 Status

🧱 Core CI/CD and Docker hardening implemented  
🔐 Security scans live and integrated  
🌩️ Terraform deployment to AWS — *coming next*

---

## 📎 Next Milestones

- ✅ Trivy integration for container scans
- ✅ Docker hardening with 0 vulnerabilities
- ✅ Semgrep SAST integration
- ⏳ IaC & secrets scanning (next)
- ⏳ Deploy to AWS securely via Terraform

---

## 🙋‍♂️ Maintainer

**Pravin Funde**  
*Application Security Engineer | DevSecOps Learner*

---

 