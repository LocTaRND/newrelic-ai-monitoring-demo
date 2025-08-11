# Monitoring Guide

This guide explains how to monitor your demo application using New Relic.

## 1. New Relic Setup
- Ensure you have a New Relic account and license key.
- Update `deployment/newrelic/values.yaml` and secrets with your license key and configuration.

## 2. Application Instrumentation
- .NET API: Uses New Relic APM agent (see Dockerfile and appsettings)
- Python app: Uses New Relic Python agent (see newrelic.ini)
- React app: Uses New Relic Browser agent (see newrelic.js)

## 3. Deploy New Relic Components
```sh
kubectl apply -f deployment/newrelic/
```

## 4. Access New Relic Dashboards
- Log in to your New Relic account
- View APM, Browser, and Infrastructure dashboards

## 5. Troubleshooting
- Check pod logs for agent startup messages
- Ensure license key is correct in secrets

---
For more details, refer to New Relic documentation or the configuration files in the `deployment/newrelic/` directory.
