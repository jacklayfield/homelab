# Homelab DevOps Platform

A local DevOps homelab for experimenting with:

* Docker and containerization
* Kubernetes (via Docker Desktop)
* Ingress (NGINX)
* CI/CD with GitHub Actions
* Helm (Kubernetes package management)
* Observability (Prometheus and Grafana)
* And more to come

---

## Architecture Overview

```text
Browser → Ingress → Web Service → API Service
                     ↓
                 Kubernetes Cluster
                     ↓
              Prometheus + Grafana
```

---

## Prerequisites

Make sure you have the following installed:

* Docker Desktop (with Kubernetes enabled)
* kubectl
* Helm
* (Optional) Task runner (`task`) or Make

---

## Project Structure

```text
homelab/
├── homelab-chart/        # Helm chart (main app deployment)
├── scripts/              # Setup scripts (e.g. monitoring)
├── Taskfile.yml          # Dev commands
├── .github/workflows/    # CI pipeline
└── README.md
```

---

## 1. Start Kubernetes

Open Docker Desktop and ensure:

```text
Kubernetes → Enabled
```

Verify:

```bash
kubectl get nodes
```

---

## 2. Deploy the Application (Helm)

Install the app:

```bash
helm install homelab ./homelab-chart
```

Upgrade after changes:

```bash
helm upgrade homelab ./homelab-chart
```

Check resources:

```bash
kubectl get pods
kubectl get services
kubectl get ingress
```

---

## 3. Access the Application

Open in browser:

```text
http://localhost/
http://localhost/api
```

---

## 4. Install Monitoring Stack

Run:

```bash
./scripts/install-monitoring.sh
```

This installs:

* Prometheus
* Grafana
* Kubernetes metrics exporters

---

## 5. Access Grafana

Port forward:

```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```

Open:

```text
http://localhost:3000
```

Login:

* Username: `admin`
* Password:

```bash
kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

---

## Common Commands

If using Taskfile:

```bash
task deploy        # Apply Helm chart
task destroy       # Remove resources
task monitor       # Install monitoring
task grafana       # Port-forward Grafana
task pods          # List pods
```

---

## CI/CD

GitHub Actions automatically:

* Builds Docker image
* Tags with `latest` and commit SHA
* Pushes to GHCR

Image format:

```text
ghcr.io/<username>/homelab-web:latest
```

---

## Key Concepts Demonstrated

* Containerized services (web and API)
* Kubernetes deployments and services
* Ingress-based routing
* Horizontal scaling (replicas)
* Health checks (liveness and readiness)
* Helm packaging
* Observability stack

---

## Cleanup

Remove the app:

```bash
helm uninstall homelab
```

Remove monitoring:

```bash
helm uninstall monitoring -n monitoring
```

---

## Docker Desktop Kubernetes Help

WSL2 manages resources for Docker Desktop Kubernetes.

A common issue is that it doesn't have enough resources to start the cluster

To fix, create/edit: C:\Users\<your-user>\.wslconfig

Create the following config in that file:

```text
[wsl2]
memory=6GB
processors=4
swap=2GB
```

Then in powershell:

```text
wsl --shutdown
```

Then restart Docker Desktop (May have to restart machine as well)

If Docker Desktop won't start try running these commands:

```bash
taskkill /f /im "Docker Desktop.exe"
taskkill /f /im "com.docker.backend.exe"
```
---

## Future Improvements

* HTTPS (TLS with cert-manager)
* Multiple environments (dev/staging/prod)
* CI to auto-deploy via Helm
* Secrets management
* Autoscaling (HPA)

---

# Install NGINX Ingress Controller: 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml