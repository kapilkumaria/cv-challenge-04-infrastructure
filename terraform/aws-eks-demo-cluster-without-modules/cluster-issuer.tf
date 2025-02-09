resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "60s"  # Adjust as needed
}

resource "kubectl_manifest" "letsencrypt_cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: kapil.kumaria@gmail.com  # Replace with your real email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
  YAML

    depends_on = [
      helm_release.cert_manager,
      # kubernetes_namespace.cert_manager,
      time_sleep.wait_for_cert_manager,
    ]
}

