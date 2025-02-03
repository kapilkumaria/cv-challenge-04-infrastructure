# Deploying Elasticsearch on Kubernetes

## **Introduction**
This guide explains how to deploy **Elasticsearch on Kubernetes** using a **StatefulSet** for persistent storage and a **NodePort Service** for access.

---

## **Step 1: Create a Namespace**

```sh
kubectl create namespace elastic-stack
kubectl config set-context --current --namespace=elastic-stack
```
Verify the namespace:
```sh
kubectl get ns
```

---

## **Step 2: Create a Persistent Volume**

### **PersistentVolume (PV) Configuration**
Create a file named `es-pvolume.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-elasticsearch
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/elasticsearch
```

Apply the PV:
```sh
kubectl apply -f es-pvolume.yaml
kubectl get pv
kubectl describe pv
```

---

## **Step 3: Create a Kubernetes Service**

### **Service Configuration**
Create a file named `es-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: elastic-stack
spec:
  selector:
    app: elasticsearch
  ports:
    - port: 9200
      targetPort: 9200
      nodePort: 30200  
      name: port1
    - port: 9300
      targetPort: 9300
      nodePort: 30300  
      name: port2
  type: NodePort
```

Apply the service:
```sh
kubectl apply -f es-service.yaml
kubectl get svc -n elastic-stack
```

---

## **Step 4: Create the StatefulSet for Elasticsearch**

### **StatefulSet Configuration**
Create a file named `es-statefulset.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: elastic-stack  
spec:
  serviceName: "elasticsearch"
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:7.1.0
        ports:
        - containerPort: 9200
          name: port1
        - containerPort: 9300
          name: port2
        env:
        - name: discovery.type
          value: single-node
        volumeMounts:
        - name: es-data
          mountPath: /usr/share/elasticsearch/data
      initContainers:
      - name: fix-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]
        securityContext:
            privileged: true
        volumeMounts:
        - name: es-data
          mountPath: /usr/share/elasticsearch/data
  volumeClaimTemplates:
  - metadata:
      name: es-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
```

Apply the StatefulSet:
```sh
kubectl apply -f es-statefulset.yaml
kubectl get statefulset -n elastic-stack
```

---

## **Step 5: Verify the Deployment**

Check if the pod is running:
```sh
kubectl get pods -n elastic-stack
```

### **Scale the StatefulSet (if needed)**
```sh
kubectl scale statefulset elasticsearch --replicas=1 -n elastic-stack
```

### **Manually edit the StatefulSet (if needed)**
```sh
kubectl edit statefulset elasticsearch -n elastic-stack
```

Check if Elasticsearch is accessible:
```sh
kubectl get svc -n elastic-stack
kubectl get pods -n elastic-stack
```

---

## **Step 6: Access Elasticsearch**

From within the Kubernetes cluster:
```sh
curl http://elasticsearch.elastic-stack.svc.cluster.local:9200
```

From outside using the **NodePort**:
```sh
curl http://<NODE_IP>:30200
```
Replace `<NODE_IP>` with the IP of any Kubernetes worker node.

---

## **Conclusion**

This setup ensures:
- **Stable identity and persistent storage** for Elasticsearch via **StatefulSet**.
- **Persistent data across pod restarts** via **PersistentVolumes**.
- **Network access to Elasticsearch** via **NodePort Service**.

### **Next Steps:**
- Deploy **Kibana** for visualization.
- Use **Fluentd** for log collection.
- Configure **replication and sharding** for high availability.

🚀 Happy Deploying! 🚀
