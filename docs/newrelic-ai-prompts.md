# New Relic AI Assistant Prompts Guide

This document provides sample prompts and queries to effectively use New Relic's AI assistant for monitoring and troubleshooting your microservices demo application.

## 🔍 General Application Health

### Basic Health Check
```
Show me the overall health of my microservices application in the last 24 hours
```

### Performance Overview
```
What is the performance summary for my .NET API, Python app, and React frontend?
```

### Error Analysis
```
Analyze all errors across my microservices and identify the most critical issues
```

```
Analyze all errors across my microservices and identify the most critical issues, also show the service name
```

## 🐛 Troubleshooting & Diagnostics

### High Response Time Investigation
```
My API response times are high. Help me identify the root cause and suggest optimizations
```

### Memory Usage Analysis
```
Analyze memory usage patterns for my Python application and detect any memory leaks
```

### Database Performance
```
Show me PostgreSQL database performance issues affecting my .NET API
```

### Error Rate Spike
```
I'm seeing increased error rates in my application. What's causing this and how can I fix it?
```

## 🤖 AI Monitoring Specific

### ML Model Performance
```
Analyze the performance of my ML models in the Python application, including inference latency and accuracy metrics
```

### AI Model Drift Detection
```
Check for model drift in my Python AI application and suggest when retraining might be needed
```

### Custom AI Metrics
```
Show me custom AI metrics for my machine learning workloads and identify any anomalies
```

## 📊 Capacity Planning

### Resource Utilization
```
Analyze resource utilization across my Kubernetes cluster and recommend scaling strategies
```

### Traffic Patterns
```
Show me traffic patterns for my React frontend and predict future capacity needs
```

### Cost Optimization
```
Suggest cost optimization opportunities for my microservices infrastructure
```

## 🚨 Alert Configuration

### Smart Alerting Setup
```
Help me set up intelligent alerts for my microservices that minimize false positives
```

### SLA Monitoring
```
Configure SLA monitoring for my user-facing services with appropriate thresholds
```

### Anomaly Detection
```
Set up anomaly detection for my application performance metrics
```

## 🔄 Deployment & Release

### Deployment Impact Analysis
```
Analyze the impact of my latest deployment on application performance and user experience
```

### Release Comparison
```
Compare performance metrics before and after my recent release
```

### Rollback Decision Support
```
Should I rollback my latest deployment? Show me the performance impact data
```

## 🏗️ Architecture Insights

### Service Dependencies
```
Map out the dependencies between my microservices and identify potential bottlenecks
```

### Performance Bottlenecks
```
Identify performance bottlenecks in my service-to-service communication
```

### Optimization Recommendations
```
Suggest architecture improvements for my microservices based on performance data
```

## 📈 Business Impact

### User Experience Analysis
```
How is application performance affecting user experience and business metrics?
```

### Revenue Impact
```
Calculate the business impact of performance issues on user engagement
```

### Customer Journey Analysis
```
Analyze the customer journey through my application and identify friction points
```

## 🔧 Best Practices for AI Prompts

### 1. Be Specific
- Include timeframes (last 24 hours, past week)
- Mention specific services or components
- Reference particular metrics or KPIs

### 2. Provide Context
- Mention recent changes or deployments
- Include relevant business context
- Specify user impact or business criticality

### 3. Ask Follow-up Questions
```
Based on this analysis, what should I investigate next?
```

```
Can you drill down into the root cause of this issue?
```

```
What preventive measures can I implement?
```

### 4. Request Actionable Insights
```
Give me 3 specific actions I can take to improve this metric
```

```
Create a step-by-step troubleshooting plan for this issue
```

```
Prioritize these issues by business impact
```

## 🎯 Advanced AI Queries

### Predictive Analysis
```
Predict when my application might experience performance issues based on current trends
```

### Correlation Analysis
```
Find correlations between infrastructure metrics and application performance
```

### Automated Root Cause Analysis
```
Automatically identify the root cause of the performance degradation that started 2 hours ago
```

### Custom Dashboard Creation
```
Create a custom dashboard for my microservices that shows the most important KPIs for my team
```

## 💡 Tips for Better Results

1. **Include relevant tags and labels** in your queries
2. **Reference specific time periods** when issues occurred
3. **Mention the business impact** of issues
4. **Ask for comparative analysis** (before/after, different environments)
5. **Request specific metrics** rather than general overviews
6. **Follow up** on recommendations with implementation questions

## 📚 Additional Resources

- [New Relic AI Documentation](https://docs.newrelic.com/docs/new-relic-solutions/new-relic-one/core-concepts/what-is-new-relic-ai/)
- [Best Practices for AI Monitoring](https://docs.newrelic.com/docs/alerts-applied-intelligence/)
- [Custom Metrics Guide](https://docs.newrelic.com/docs/data-apis/custom-data/)

---

Remember: The more context and specific details you provide in your prompts, the better and more actionable the AI assistant's responses will be!
