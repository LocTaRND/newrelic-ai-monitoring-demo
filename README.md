# NewRelic Demo Project

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

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd demo
```

### 2. Set Up K3s Cluster
```bash
cd k3s-setup
chmod +x setup-k3s.sh
./setup-k3s.sh
```

### 3. Deploy PostgreSQL
```bash
cd postgresql
chmod +x deploy-postgresql-helm.sh
./deploy-postgresql-helm.sh
```

### 4. Configure Secrets
```bash
# Create your secrets based on the template
cp deployment/secrets/secrets.yaml.template deployment/secrets/secrets.yaml
# Edit the secrets file with your actual values
```

### 5. Deploy Applications
```bash
cd deployment
kubectl apply -f app/
kubectl apply -f newrelic/
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

## 🔐 Security

- All sensitive configuration is stored in Kubernetes secrets
- Secret files are excluded from version control via `.gitignore`
- Follow principle of least privilege for service accounts
- Regular security updates recommended

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
