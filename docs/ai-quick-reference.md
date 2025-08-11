# New Relic AI Assistant Quick Reference

## 🚀 Quick Start Prompts

Copy and paste these prompts directly into New Relic's AI assistant:

### Application Health
```
Show me the health status of all my microservices in the last 4 hours
```

### Performance Issues
```
What are the top 3 performance issues affecting my users right now?
```

### Error Investigation
```
Analyze all 5xx errors in my .NET API from the past hour and suggest fixes
```

### AI Model Monitoring
```
Check the performance of my Python ML models - are there any accuracy or latency issues?
```

## 🎯 Scenario-Based Prompts

### When Users Report Slow Response
```
Users are complaining about slow page loads. Analyze my React frontend performance and identify bottlenecks in the last 2 hours.
```

### After a Deployment
```
I just deployed a new version 30 minutes ago. Compare performance metrics before and after deployment and highlight any regressions.
```

### Database Issues
```
My PostgreSQL database seems slow. Show me query performance and connection pool metrics for the last hour.
```

### Kubernetes Scaling
```
Analyze my Kubernetes cluster resource usage and recommend if I need to scale up any services.
```

## 🔧 Troubleshooting Templates

### High CPU Usage
```
Service: [SERVICE_NAME]
Issue: High CPU usage detected
Timeframe: [TIME_PERIOD]
Request: Identify what's causing high CPU and suggest optimizations
```

### Memory Leaks
```
Service: [SERVICE_NAME]
Issue: Suspected memory leak
Timeframe: [TIME_PERIOD]
Request: Analyze memory usage patterns and identify leak sources
```

### API Latency
```
Service: [API_NAME]
Issue: Increased response times
Timeframe: [TIME_PERIOD]
Request: Break down latency by endpoint and identify slow operations
```

## 💡 Pro Tips

1. **Always include timeframes** (last hour, past 24 hours, since deployment)
2. **Mention specific services** (.NET API, Python app, React frontend)
3. **Ask for actionable recommendations**, not just analysis
4. **Follow up** with "What should I do next?" or "How can I prevent this?"

## 🔗 Related Documentation

- [Full AI Prompts Guide](./newrelic-ai-prompts.md)
- [Monitoring Setup](./monitoring.md)
- [Deployment Guide](./deploy.md)
