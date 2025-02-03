# **Deploy Fluentd on Kubernetes using a DaemonSet**

## **Introduction**
In this guide, we will deploy **Fluentd** on Kubernetes using a **DaemonSet**. This setup enables log collection from all Kubernetes nodes and forwarding to **Elasticsearch** for centralized logging and analysis.

## **1. Understanding Fluentd and DaemonSet**
### **Why Use a DaemonSet?**
- A **DaemonSet** ensures that **Fluentd runs on every node** in the Kubernetes cluster.
- This guarantees consistent log collection across all containers.

### **What is a DaemonSet?**
A **DaemonSet** is a Kubernetes resource that ensures a Pod runs on all (or selected) nodes. It is commonly used for:
- Log collection agents (**Fluentd**, **Logstash**)
- Monitoring tools (**Prometheus Node Exporter**, **Datadog**)
- Networking plugins (**CNI plugins like Calico, Weave**)

---

## **2. Find the Current Namespace**
```sh
kubectl config view --minify --output 'jsonpath={..namespace}'
```
This command returns the active namespace where resources will be deployed.

---

## **3. Create a ServiceAccount for Fluentd**

### **Why?**
A **ServiceAccount** is required to allow Fluentd to securely interact with the Kubernetes API.

```yaml
# fluentd-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: elastic-stack
  labels:
    app: fluentd
```

**Apply the ServiceAccount:**
```sh
kubectl apply -f fluentd-sa.yaml
kubectl get sa
```

---

## **4. Assign Permissions Using a ClusterRole**
### **Why?**
Fluentd needs **get, list, and watch** permissions to read logs from Pods and Namespaces.

```yaml
# fluentd-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluentd
  labels:
    app: fluentd
rules:
- apiGroups: [""]
  resources:
    - pods
    - namespaces
  verbs:
    - get
    - list
    - watch
```

**Apply the ClusterRole:**
```sh
kubectl apply -f fluentd-clusterrole.yaml
kubectl get clusterrole fluentd
```

---

## **5. Bind the ServiceAccount to the ClusterRole**
```yaml
# fluentd-clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluentd
roleRef:
  kind: ClusterRole
  name: fluentd
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: elastic-stack
```

**Apply the ClusterRoleBinding:**
```sh
kubectl apply -f fluentd-clusterrolebinding.yaml
kubectl get clusterrolebinding
```

---

## **6. Create Fluentd Configuration**

### **Why?**
This configuration file defines how Fluentd will collect and forward logs.

```sh
mkdir -p /root/fluentd/etc/
```

```yaml
# fluentd/etc/fluent.conf
<label @FLUENT_LOG>
<match fluent.**>
  @type null
  @id ignore_fluent_logs
</match>
</label>

<source>
  @type tail
  @id in_tail_container_logs
  path "/var/log/containers/*.log"
  pos_file "/var/log/fluentd-containers.log.pos"
  tag "kubernetes.*"
  exclude_path /var/log/containers/fluent*
  read_from_head true
  <parse>
    @type regexp
    expression ^(?<time>.+) (?<stream>stdout|stderr)( (?<logtag>.))? (?<log>.*)$
    time_format "%Y-%m-%dT%H:%M:%S.%NZ"
  </parse>
</source>

<match **>
  @type elasticsearch
  host "elasticsearch.elastic-stack.svc.cluster.local"
  port 9200
  scheme http
  ssl_verify false
  logstash_format true
  logstash_prefix "fluentd"
  <buffer>
    flush_thread_count 8
    flush_interval 5s
    chunk_limit_size 2M
    retry_forever true
  </buffer>
</match>
```

---

## **7. Deploy Fluentd as a DaemonSet**

### **Why?**
Ensures Fluentd runs on every node for complete log collection.

```yaml
# fluentd.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: elastic-stack
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      serviceAccountName: fluentd
      tolerations:
      - key: "node-role.kubernetes.io/master"
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1.14.1-debian-elasticsearch7-1.0
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch.elastic-stack.svc.cluster.local"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        - name: FLUENT_ELASTICSEARCH_SCHEME
          value: "http"
        - name: FLUENT_ELASTICSEARCH_LOGSTASH_PREFIX
          value: "fluentd"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: configpath
          mountPath: /fluentd/etc
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: configpath
        hostPath:
          path: /root/fluentd/etc
```

**Apply the DaemonSet:**
```sh
kubectl apply -f fluentd.yaml
kubectl get ds
```

---

## **8. Verify Fluentd Logs in Elasticsearch**

```sh
kubectl logs -l app=fluentd -n elastic-stack
```

### **Check Elasticsearch Logs**
- Open **Elasticsearch** in a browser.
- Add `/_search?q=*:*&pretty` to the URL.
- You should see logs indexed in Elasticsearch.

---

## **9. Validate Log Collection**
```sh
kubectl logs -l app=my-app -n elastic-stack
```

---

## **Conclusion**
This setup ensures that:
- Fluentd runs **on every Kubernetes node** via **DaemonSet**.
- Logs from **all Pods** are collected.
- Logs are forwarded to **Elasticsearch** for centralized storage and analysis.

🚀 **Now you have centralized logging in your Kubernetes cluster!**
