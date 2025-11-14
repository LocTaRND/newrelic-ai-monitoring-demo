
![MIT License](https://img.shields.io/badge/license-MIT-green)
![Kubernetes](https://img.shields.io/badge/kubernetes-K3s-blue)
![New Relic](https://img.shields.io/badge/monitoring-NewRelic-brightgreen)

# NewRelic Demo Project
A comprehensive multi-service demo application showcasing microservices architecture with New Relic monitoring integration, deployed on Kubernetes.

---

## 📑 Table of Contents

- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Local Development](#-local-development)
- [Monitoring](#-monitoring)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#faq)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact & Support](#contact--support)

A comprehensive multi-service demo application showcasing microservices architecture with New Relic monitoring integration, deployed on Kubernetes.

## 🏗️ Architecture

This demo consists of three main services:

### Applications
- **🔧 .NET Core Web API** (`application/dotnet/`)
  - RESTful API with user management
  - Entity Framework Core with PostgreSQL
  - Health checks and error handling
  - New Relic APM integration

- **🐍 Python Application** (`application/python/`)
  - Python web service with AI/ML capabilities
  - New Relic AI monitoring for ML model performance
  - APM integration with custom AI metrics tracking
  - Containerized with Docker

- **⚛️ React Frontend** (`application/react-crud-app/`)
  - CRUD operations interface
  - User management UI
  - Browser monitoring with New Relic
  - Built with modern React

### Infrastructure
- **📊 Monitoring**: New Relic APM, Browser, and AI monitoring
- **🤖 AI Observability**: ML model performance and inference monitoring
- **🗄️ Database**: PostgreSQL with Helm deployment
- **☸️ Orchestration**: Kubernetes (K3s) cluster
- **🐳 Containerization**: Docker containers for all services


## 📋 Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (K3s recommended)
- Helm 3.x
- .NET 8 SDK (for local development)
- Node.js 16+ (for local development)
- Python 3.9+ (for local development)

**Tested Platforms:**
- Ubuntu 22.04 LTS
- Windows 11
- macOS Monterey

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/LocTaRND/newrelic-ai-monitoring-demo.git
cd newrelic-ai-monitoring-demo
```

### 2. Set Up K3s Cluster
```bash
cd k3s-setup
chmod +x setup-k3s.sh
./setup-k3s.sh
```

### 3. Deploy PostgreSQL
```bash
cd ../postgresql
chmod +x deploy-postgresql-helm.sh
./deploy-postgresql-helm.sh
```

### 4. Build and Push docker applications image into Docker registry
```bash
# Create your secrets based on the template
cd ../application
chmod +x script.sh
# Without integration with New Relic
./script.sh without-newrelic
# Integration with New Relic
./script.sh with-newrelic
```


### 5. Configure Secrets
```bash
# Create your secrets based on the template
cd ..
cp deployment/secrets/secrets.yaml.template deployment/secrets/secrets.yaml
# Then update the secrets into the secrets.yaml file
# Edit the secrets file with your actual values
```

⚠️ **Never commit `secrets.yaml` to version control. Rotate secrets regularly and follow your organization's security policies.**

### 6. Deploy Applications
```bash
cd deployment
# Without New Relic
chmod +x script.sh
./script.sh apply force # for run the first time or if you want to always deploy
# With New Relic
chmod +x script-with-newrelic.sh
./script-with-newrelic.sh apply force # for run the first time or if you want to always deploy
```

## 🛠️ Local Development

### .NET API
```bash
cd application/dotnet
dotnet restore
dotnet run
```

### Python App
```bash
cd application/python
pip install -r requirements.txt
python app.py
```

### React Frontend
```bash
cd application/react-crud-app
npm install
npm start
```


## 📊 Monitoring

This demo includes comprehensive monitoring with New Relic:

- **APM Monitoring**: Backend services instrumentation
- **AI Monitoring**: Python app includes New Relic AI monitoring for:
  - ML model performance tracking
  - Inference latency and throughput metrics
  - Model accuracy and drift detection
  - Custom AI/ML application metrics
- **Browser Monitoring**: Frontend performance tracking
- **Infrastructure Monitoring**: Kubernetes cluster metrics
- **Custom Dashboards**: Pre-configured monitoring views


Access your New Relic dashboard to view real-time metrics and performance data.

**Useful Links:**
- [New Relic Documentation](https://docs.newrelic.com/)
- [K3s Documentation](https://rancher.com/docs/k3s/latest/en/)
- [Helm Documentation](https://helm.sh/docs/)


## 🔐 Security

- All sensitive configuration is stored in Kubernetes secrets
- Secret files are excluded from version control via `.gitignore`
- Follow principle of least privilege for service accounts
- Regular security updates recommended
- Use network policies and RBAC for Kubernetes security
- Keep Docker images and dependencies up to date
## 🛡️ Troubleshooting

- **K3s service not starting:**
  - Run `sudo systemctl status k3s` and check logs with `sudo journalctl -u k3s -f`.
- **New Relic agent not reporting:**
  - Ensure your license key is correct and network access to New Relic endpoints is allowed.
- **Docker build errors:**
  - Check Docker daemon status and available disk space.
- **Helm install issues:**
  - Run `helm list` and `helm status <release>` for more info.

## ❓ FAQ

**Q: How do I get a New Relic license key?**
A: Sign up at [New Relic](https://newrelic.com/) and find your key in the account settings.

**Q: How do I reset the K3s cluster?**
A: Use the scripts in `k3s-setup/` or follow the K3s documentation for cluster reset.

**Q: How do I update secrets?**
A: Edit `deployment/secrets/secrets.yaml` and re-apply with `kubectl apply -f deployment/secrets/secrets.yaml`.

**Q: Where can I find more documentation?**
A: See the links in the Monitoring section above.
## Contact & Support

For questions, issues, or feedback, please open an issue on this repository or contact the maintainer at [your-email@example.com].

## 📁 Project Structure

```
├── application/           # Application services
│   ├── dotnet/           # .NET Core Web API
│   ├── python/           # Python application
│   └── react-crud-app/   # React frontend
├── deployment/           # Kubernetes manifests
│   ├── app/             # Application deployments
│   ├── newrelic/        # New Relic configuration
│   └── secrets/         # Secret configurations
├── k3s-setup/           # Cluster setup scripts
└── postgresql/          # Database deployment
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
