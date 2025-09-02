

I'm seeing increased error rates in my application. What's causing this and how can I fix it?

FROM TransactionError
SELECT count(*) AS 'Error Count', latest(error.message) AS 'Error Message', latest(error.class) AS 'Error Class'
FACET appName, transactionName
SINCE 1 hour ago


### Ask about K8S

FROM K8sContainerSample 
SELECT average(cpuUsedCores) AS 'Average CPU Used Cores', max(cpuUsedCores) AS 'Max CPU Used Cores', min(cpuUsedCores) AS 'Min CPU Used Cores' 
FACET podName 
SINCE 1 hour ago 

# My pods are experiencing high CPU usage. Help me analyze the metrics in New Relic

FROM K8sContainerSample 
SELECT average(cpuUsedCores) AS 'Average CPU Used Cores', max(cpuUsedCores) AS 'Max CPU Used Cores', min(cpuUsedCores) AS 'Min CPU Used Cores' 
FACET podName 
SINCE 1 hour ago 

# How can I use New Relic to identify which pods are consuming the most memory in my cluster?

FROM K8sContainerSample 
SELECT max(memoryUsedBytes) AS 'Max Memory Used' 
FACET podName 
SINCE 1 hour ago 
LIMIT 10

# Create a New Relic dashboard query to show pod evicted, pending, error … frequency across namespaces

FROM K8sPodSample 
SELECT count(*) WHERE status IN ('Failed', 'Pending', 'Unknown') 
FACET namespaceName, status 
SINCE 24 hours ago 
TIMESERIES

# Create a New Relic dashboard query to show pod restart frequency across namespaces

FROM K8sPodSample SELECT sum(restartCountDelta) AS 'Pod Restart Frequency' FACET namespaceName SINCE 1 hour ago TIMESERIES