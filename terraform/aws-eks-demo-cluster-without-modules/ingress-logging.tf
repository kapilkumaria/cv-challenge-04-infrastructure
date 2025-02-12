resource "kubectl_manifest" "ingress-logging" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: logging-ingress
  namespace: logging
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - kapilkumaria.com
    - www.kapilkumaria.com
    secretName: kapilkumaria-tls  # Cert will be stored here
  rules:
  - host: "kapilkumaria.com"
    http:
      paths:
      - path: "/kibana"
        pathType: Prefix
        backend:
          service:
            name: kibana-kibana
            port:
              number: 5601

      - path: "/elasticsearch"
        pathType: Prefix
        backend:
          service:
            name: elasticsearch-master
            port:
              number: 9200

      - path: "/fluent-bit"
        pathType: Prefix
        backend:
          service:
            name: fluent-bit
            port:
              number: 2020
  
  YAML
 
  depends_on = [helm_release.cert_manager]
}

# resource "kubectl_manifest" "certificate" {
#   yaml_body = <<YAML
# apiVersion: cert-manager.io/v1
# kind: Certificate
# metadata:
#   name: kapilkumaria-tls
#   namespace: argocd
# spec:
#   secretName: kapilkumaria-tls
#   issuerRef:
#     name: letsencrypt-prod
#     kind: ClusterIssuer
#   commonName: kapilkumaria.com
#   dnsNames:
#   - kapilkumaria.com
#   - www.kapilkumaria.com
#   YAML
# }
