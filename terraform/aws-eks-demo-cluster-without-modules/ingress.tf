resource "kubectl_manifest" "ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  rules:
  - host: "kapilkumaria.com"
    http:
      paths:
      - path: "/argocd"
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80

      - path: "/adservice"
        pathType: Prefix
        backend:
          service:
            name: adservice
            port:
              number: 9555

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
}
