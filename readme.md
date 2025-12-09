# Portfolio Serverless Website

## 📌 Overview
This [My Portfolio](https://www.tunlab.xyz) project demonstrates a fully serverless, scalable, and high-performance portfolio website hosted entirely on AWS.

Infrastructure is deployed using **Terraform Cloud**, and **GitHub Actions** automatically triggers deployment pipelines on every push.
The backend includes a serverless visitor counter API, and the frontend is globally delivered via CloudFront from an S3 bucket.


## Architecture Diagram
![alt text](images/diagram.png)

---
## 🚀 Features

### **Frontend**
- Static portfolio website hosted on **S3**
- Global CDN delivery and caching via **CloudFront**
- Custom domain managed with **Route 53**
- HTTPS enabled using **AWS ACM**

### **Backend**
- AWS **Lambda** for serverless API logic
- **API Gateway (HTTP API)** exposing visitor-count API
- **DynamoDB** table for storing the visitor counter
- **CloudWatch** for logging and metric tracking

### **Deployment**
- **GitHub Actions** : triggers Terraform Cloud on every push
- **Terraform Cloud** : remote state, plan, and apply
- Modular infrastructure design:
  - `modules/frontend`
  - `modules/backend`
---
## 📁 Folder Structure

```bash
.
├── backend.tf                    # Terraform Cloud backend configuration
├── images/
│   └── diagram.png               # Architecture diagram
├── main.tf                       # Root Terraform entrypoint
├── modules/
│   ├── backend/                  # Visitor Counter API Infrastructure (Lambda, API GW, DynamoDB,IAM Role)
│   │   ├── lambda/
│   │   │   └── visitor_counter.zip
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── frontend/                 # Static Website Infrastructure (S3, CF, Route53)
│       ├── data.tf
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── provider.tf                   # AWS provider configuration
├── readme.md                     # Project documentation
├── variable.tf                   # Root input variables
└── version.tf                    # Terraform version constraints
├── version.tf
└── website                       # Static Website Source Code (HTML, CSS, JS)
    ├── app.js
    ├── images                    # Portfolio website images
    ├── index.html
    └── style.css

```