resource "kubectl_manifest" "ingress-argocd" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    
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
      - path: "/"
        pathType: Exact
        backend:
          service:
            name: argocd-server
            port:
              number: 80    
            
  - host: "www.kapilkumaria.com"
    http:
      paths:
      - path: "/"
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
  YAML
 
  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "certificate" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: kapilkumaria-tls
  namespace: argocd
spec:
  secretName: kapilkumaria-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: kapilkumaria.com
  dnsNames:
  - kapilkumaria.com
  - www.kapilkumaria.com
  YAML
}
