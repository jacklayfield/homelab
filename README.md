# Homelab DevOps Platform

A full-featured local DevOps homelab for experimenting with:

* **Container Orchestration**: Docker and Kubernetes (via Docker Desktop)
* **Deployment**: Helm charts for package management
* **Ingress**: NGINX-based routing and load balancing
* **CI/CD**: GitHub Actions workflows for automated builds and deployments
* **Observability**: Prometheus for metrics collection and Grafana for visualization
* **Alerting**: Prometheus alert rules for monitoring and incident response

This is a comprehensive platform designed to mirror production-like infrastructure on your local machine.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐              ┌──────────────────┐     │
│  │   INGRESS/NGINX  │              │    MONITORING    │     │
│  │    (Routing)     │              │    NAMESPACE     │     │
│  └────────┬─────────┘              └────────┬─────────┘     │
│           │                                 │               │
│  ┌────────▼───────────────────────┐  ┌──────▼─────────┐     │
│  │        DEFAULT NAMESPACE       │  │  PROMETHEUS    │     │
│  ├────────────────────────────────┤  │  (Scraping)    │     │
│  │                                │  └────────┬───────┘     │
│  │ ┌─────────────┐  ┌───────────┐ │           │             │
│  │ │ Web Service │  │API Service│ │  ┌────────▼───────┐     │
│  │ │ (3 replicas)│  │(2 replicas) │  │  │GRAFANA      │     │
│  │ └─────────────┘  └───────────┘ │  │  (Dashboards)  │     │
│  │                                │  └────────────────┘     │
│  └────────────────────────────────┘                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                           │
                ┌──────────┴──────────┐
                │                     │
            ┌───▼───┐            ┌───▼───┐
            │Browser│            │Metrics│
            └───────┘            └───────┘
```
---

## Prerequisites

Make sure you have the following installed:

* **Docker Desktop** (with Kubernetes enabled) - [Download](https://www.docker.com/products/docker-desktop)
* **kubectl** - Kubernetes command-line tool
* **Helm 3** - Kubernetes package manager  
* **Task** (optional) - Modern task runner (`brew install go-task` or `choco install go-task`)

### Quick Setup

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Task (optional but recommended)
brew install go-task  # macOS
# or
choco install go-task  # Windows
# or see https://taskfile.dev/installation/
```

---

## Project Structure

```
homelab/
├── app/                          # Application source code
│   ├── Dockerfile               # Docker image definition
│   ├── index.html               # Web content
│   └── nginx.conf               # NGINX configuration
│
├── homelab-chart/               # Helm chart (main deployment)
│   ├── Chart.yaml               # Chart metadata
│   ├── values.yaml              # Default configuration values
│   └── templates/               # Kubernetes manifests templates
│       ├── web-deployment.yaml
│       ├── api-deployment.yaml
│       ├── web-service.yaml
│       ├── api-service.yaml
│       ├── ingress.yaml
│       ├── serviceaccount.yaml
│       └── _helpers.tpl
│
├── monitoring/                  # Monitoring stack
│   ├── namespace.yaml           # Monitoring namespace
│   ├── prometheus/              # Prometheus configuration
│   │   ├── configmap.yaml       # Scrape configs
│   │   ├── rules.yaml           # Alert rules
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── serviceaccount.yaml
│   │   ├── clusterrole.yaml
│   │   └── clusterrolebinding.yaml
│   └── grafana/                 # Grafana configuration
│       ├── datasources.yaml     # Prometheus datasource
│       ├── dashboards.yaml      # Dashboard providers
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── serviceaccount.yaml
│       └── secret.yaml
│
├── kubernetes/                  # Raw Kubernetes manifests (legacy)
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── api-deployment.yaml
│   └── api-service.yaml
│
├── scripts/                     # Utility scripts
│   ├── setup.sh                 # Setup script
│   ├── setup-windows.sh         # Windows setup
│   ├── install-monitoring.sh    # Monitoring installation
│   ├── healthcheck.sh           # Health checks
│   ├── logs.sh                  # Log retrieval
│   └── stop.sh                  # Cleanup script
│
├── .github/workflows/           # GitHub Actions CI/CD
│   ├── build.yml                # Build Docker image
│   ├── deploy.yml               # Deploy to Kubernetes
│   └── lint.yml                 # Linting checks
│
├── docker/                      # Docker Compose (local dev)
│   ├── docker-compose.yml
│   └── env.template
│
├── Taskfile.yml                 # Task runner configuration
└── README.md                    # This file
```

---

## Getting Started

### 1. Start with Helm (Recommended)

Deploy the entire application stack using Helm:

```bash
# Install the Helm chart
helm install homelab ./homelab-chart --namespace default --create-namespace

# Or use Task
task helm:install
```

### 2. Deploy Monitoring Stack

```bash
# Deploy Prometheus and Grafana
kubectl apply -f monitoring/namespace.yaml
kubectl apply -f monitoring/prometheus/
kubectl apply -f monitoring/grafana/

# Or use Task
task monitor:install
```

### 3. Verify Deployment

```bash
# Check all pods
kubectl get pods -A

# Check services
kubectl get svc -A

# Check ingress
kubectl get ingress -A

# Or use Task
task status
```

---

## Accessing Services

### Web Application

**URL**: http://homelab.local (or http://localhost if DNS not configured)

```bash
# Port-forward to access locally
kubectl port-forward svc/homelab-web 8080:80

# Then visit http://localhost:8080
```

### Prometheus Metrics

**URL**: http://prometheus:9090

```bash
# Port-forward Prometheus
task forward:prometheus
# or
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Then visit http://localhost:9090
```

### Grafana Dashboards

**URL**: http://grafana:3000  
**Default Credentials**: `admin` / `admin123`

```bash
# Port-forward Grafana
task forward:grafana
# or
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Then visit http://localhost:3000
```

### API Service

**URL**: http://homelab-api:5678

```bash
# Port-forward API
task forward:app
# or
kubectl port-forward svc/homelab-api 5678:5678

# Then visit http://localhost:5678
```

---

## Using Task Commands

If you have Task installed, use these convenient commands:

### Deployment

```bash
task helm:install       # Install Helm chart
task helm:upgrade       # Upgrade Helm chart
task helm:uninstall     # Remove Helm chart
task monitor:install    # Deploy monitoring stack
task monitor:uninstall  # Remove monitoring stack
task deploy:all         # Deploy everything
```

### Status & Monitoring

```bash
task status             # Show overall cluster status
task pods               # List all pods
task pods:default       # List pods in default namespace
task pods:monitoring    # List monitoring namespace pods
task svc                # List all services
task ingress            # List all ingresses
task health             # Check deployment health
task events             # Show recent cluster events
```

### Logs & Debugging

```bash
task logs:app           # Tail application logs
task logs:api           # Tail API logs
task logs:prometheus    # Tail Prometheus logs
task logs:grafana       # Tail Grafana logs
task describe:app       # Describe app deployment
task describe:api       # Describe API deployment
```

### Port Forwarding

```bash
task forward:grafana    # Forward Grafana (3000:3000)
task forward:prometheus # Forward Prometheus (9090:9090)
task forward:app        # Forward app service (8080:80)
```

### Utilities

```bash
task lint:helm          # Lint Helm chart
task validate:manifests # Validate all manifests
task destroy            # Delete all resources
task clean              # Clean temporary files
task help               # Show all available tasks
```

---

## Configuration

### Helm Values

Customize deployment behavior by editing `homelab-chart/values.yaml`:

```yaml
# Number of replicas for web service
web:
  replicas: 3
  
# Number of replicas for API service
api:
  replicas: 2
  
# Resource limits and requests
web:
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 250m
      memory: 128Mi
```

### Environment Variables

Create a `.env` file or edit `docker/env.template`:

```bash
NGINX_PORT=8080
API_PORT=5678
```

---

## CI/CD Pipelines

### GitHub Actions Workflows

Three automated workflows are configured:

#### 1. Build Workflow (`.github/workflows/build.yml`)

Triggers on pushes to `main` or `develop` branches:

```yaml
- Builds Docker image for the web app
- Pushes to GitHub Container Registry (ghcr.io)
- Generates semantic version tags
```

**To use**: Set `GITHUB_TOKEN` in repository secrets.

#### 2. Deploy Workflow (`.github/workflows/deploy.yml`)

Triggers after successful build or on manual changes:

```yaml
- Deploys monitoring stack (Prometheus + Grafana)
- Deploys application using Helm
- Verifies rollout status
- Shows deployment information
```

**To use**: Configure `KUBE_CONFIG` secret with base64-encoded kubeconfig.

#### 3. Lint Workflow (`.github/workflows/lint.yml`)

Runs on all pull requests:

```yaml
- Lints Helm chart syntax
- Validates Kubernetes manifests
- Checks Dockerfile for best practices
```

---

## Monitoring & Alerting

### Prometheus

Prometheus automatically scrapes metrics from:

- **Kubernetes API Server**
- **Kubernetes Nodes**
- **Kubernetes Pods** (with `prometheus.io/scrape: "true"` annotation)
- **Kubernetes Services**

Default retention: **30 days**

### Alert Rules

Alert rules are defined in `monitoring/prometheus/rules.yaml`:

- **Pod crash looping** - Critical
- **Pod not healthy** - Warning
- **Container high CPU** - Warning (>90%)
- **Container high memory** - Warning (>90%)
- **Node not ready** - Critical
- **Node high CPU** - Warning (>80%)
- **Node high memory** - Warning (>80%)

### Grafana

Pre-configured with:

- Prometheus as default datasource
- Provisioned dashboards for Kubernetes monitoring
- Alert notifications (configure in UI)

---

## Troubleshooting

### Pods not starting?

```bash
# Check pod status
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Check events
kubectl get events -A
```

### Services not accessible?

```bash
# Check service endpoints
kubectl get endpoints

# Verify ingress configuration
kubectl describe ingress

# Test connectivity
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- bash
```

### Prometheus not scraping?

```bash
# Check Prometheus status
kubectl logs -n monitoring deployment/prometheus

# View scrape configs
kubectl get configmap -n monitoring prometheus-config -o yaml
```

### Grafana dashboard not showing data?

```bash
# Verify Prometheus datasource
# In Grafana UI: Configuration → Data Sources → Test

# Check metrics availability
# Visit http://localhost:9090 → Graph → Query metrics
```

---

## Cleanup

### Remove Everything

```bash
# Using Task
task destroy

# Or manually
helm uninstall homelab --namespace default
kubectl delete -f monitoring/
```

### Keep Data

To preserve data, comment out `emptyDir: {}` volumes in monitoring manifests.

---

## Advanced Topics

### Custom Dashboards

1. Login to Grafana (http://localhost:3000)
2. Create → Dashboard
3. Add panels querying Prometheus metrics
4. Export dashboard JSON and store in `monitoring/grafana/dashboards/`

### Backup & Restore

```bash
# Backup Prometheus data
kubectl cp monitoring/prometheus-0:/prometheus ./prometheus-backup -n monitoring

# Restore Prometheus data
kubectl cp ./prometheus-backup monitoring/prometheus-0:/prometheus -n monitoring
```

### High Availability

Enable HA by modifying `homelab-chart/values.yaml`:

```yaml
web:
  replicas: 5
api:
  replicas: 3
```

---

## Production Considerations

This is a **local homelab setup**. For production:

- Use managed Kubernetes (EKS, AKS, GKE)
- Configure persistent volumes (not emptyDir)
- Set resource quotas and network policies
- Enable RBAC and pod security policies
- Use sealed secrets for sensitive data
- Configure TLS/SSL certificates
- Set up log aggregation (ELK, Loki)
- Implement GitOps (ArgoCD, Flux)

---

## Contributing

1. Create feature branches from `develop`
2. Submit pull requests for review
3. Ensure all checks pass (lint, validate, build)
4. Deploy to staging before merging to `main`

---

## License

This project is provided as-is for educational and personal use.

---

## Resources

* [Kubernetes Documentation](https://kubernetes.io/docs/)
* [Helm Documentation](https://helm.sh/docs/)
* [Prometheus Documentation](https://prometheus.io/docs/)
* [Grafana Documentation](https://grafana.com/docs/)
* [Docker Desktop with Kubernetes](https://docs.docker.com/desktop/kubernetes/)
* [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Questions?** Check the [Troubleshooting](#troubleshooting) section or review logs with `task logs:*` commands.

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