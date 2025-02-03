# Deploying Kibana on Kubernetes

## Overview
This guide focuses on setting up **Kibana** to visualize logs collected by **Fluentd** and stored in **Elasticsearch** within a Kubernetes cluster.

## Prerequisites
Before deploying Kibana, ensure:
1. A **Kubernetes cluster** is up and running.
2. **Elasticsearch** is deployed and accessible within the cluster.
3. **Fluentd** is forwarding logs to Elasticsearch.

## Step 1: Create a Kubernetes Namespace for Elastic Stack

### Why?
Using a dedicated namespace helps logically separate Elasticsearch, Kibana, and Fluentd resources, making management easier.

### Command:
```sh
kubectl create namespace elastic-stack
```

### Definition:
- **Namespace:** A Kubernetes abstraction that groups resources to avoid conflicts.

## Step 2: Define and Deploy Kibana Deployment

### Why?
Kibana needs to be deployed as a **Deployment** to ensure it runs as a managed and scalable pod in Kubernetes.

### Create a Deployment YAML File
```sh
vi kibana-deployment.yaml
```

### Paste the Following Configuration:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: elastic-stack
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana:7.1.0
        ports:
        - containerPort: 5601
```

### Deploy Kibana
```sh
kubectl apply -f kibana-deployment.yaml
```

### Definition:
- **Deployment:** A Kubernetes resource that manages pod creation and updates.
- **Replica:** Ensures high availability by running multiple instances.
- **ContainerPort:** The port inside the pod where Kibana runs.

## Step 3: Verify Kibana Deployment

### Why?
To confirm that Kibana is running and ready to serve traffic.

### Command:
```sh
kubectl get pods -n elastic-stack
```

### Expected Output:
```
NAME                      READY   STATUS    RESTARTS   AGE
kibana-66b7879577-mqgwh   1/1     Running   0          42s
```

### Definition:
- **STATUS Running:** The pod is active and operational.
- **RESTARTS 0:** No issues encountered.

## Step 4: Expose Kibana via a Kubernetes Service

### Why?
To allow access to Kibana from outside the cluster.

### Create a Service YAML File
```sh
vi kibana-service.yaml
```

### Paste the Following Configuration:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: elastic-stack
spec:
  type: NodePort
  selector:
    app: kibana
  ports:
  - protocol: TCP
    port: 5601
    nodePort: 30601
```

### Apply the Service Configuration
```sh
kubectl apply -f kibana-service.yaml
```

### Definition:
- **Service:** A Kubernetes object that exposes an application.
- **NodePort:** Exposes the service on a static port across all nodes.

## Step 5: Verify Kibana Service

### Why?
To confirm Kibana is accessible via the assigned NodePort.

### Command:
```sh
kubectl get svc -n elastic-stack
```

### Expected Output:
```
NAME      TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kibana    NodePort   10.100.200.50    <none>        5601:30601/TCP   2m
```

### Access Kibana
**URL Format:** `http://<Node-IP>:30601`
- Replace `<Node-IP>` with any worker node’s IP.

## Step 6: Configure Kibana Index Pattern

### Why?
To allow Kibana to visualize logs stored in Elasticsearch.

### Steps:
1. Open Kibana UI (`http://<Node-IP>:30601`).
2. Click **Discover** in the left panel.
3. Create an **Index Pattern**:
   - Enter: `fluentd-*`
   - Click **Next Step**.
   - Choose `@timestamp` as the time field.
   - Click **Create Index Pattern**.

### Definition:
- **Index Pattern:** Defines which Elasticsearch indices to explore.

## Step 7: Query Logs in Kibana

### Why?
To analyze logs stored in Elasticsearch.

### Steps:
1. Navigate to **Discover**.
2. In the search bar, enter:
   ```
   log : USER1
   ```
3. Click **Update** to filter logs for USER1.

## Step 8: Create a Visualization in Kibana

### Why?
To gain insights by creating charts and dashboards.

### Steps:
1. Click on **Visualize**.
2. Choose a **New Visualization**.
3. Select **Data Source** (fluentd-*).
4. Create a **bar chart** showing the count of each user's logs.

### Reference:
[Creating Dashboards in Kibana](https://www.elastic.co/guide/en/kibana/current/dashboard.html)

## Step 9: Secure Kibana (Production-Ready)

### Why?
To prevent unauthorized access and protect sensitive data.

### Best Practices:
1. **Enable Authentication**:
   - Secure Elasticsearch with **Basic Auth** or **SSO**.
2. **Use TLS/SSL**:
   - Configure Kibana and Elasticsearch for **encrypted connections**.
3. **Restrict Access with Ingress**:
   - Use **Kubernetes Ingress with HTTPS** instead of NodePort.
4. **Implement Role-Based Access Control (RBAC)**:
   - Grant **least privilege access** to users.

## Final Thoughts
This guide covered:
✔️ Deploying Kibana in Kubernetes  
✔️ Exposing Kibana with a Service  
✔️ Connecting Kibana to Elasticsearch  
✔️ Querying logs using KQL  
✔️ Creating visualizations  
✔️ Securing Kibana  

With this setup, you can now **visualize logs, monitor trends, and troubleshoot issues** efficiently within your Kubernetes cluster. 🚀
