resource "kubectl_manifest" "argocd_app" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: efk-app
  namespace: argocd
spec:
  destination:
    namespace: logging
    server: https://kubernetes.default.svc
  source:
    repoURL: "https://github.com/your-github-repo/efk-helm-charts"
    path: "efk"
    targetRevision: main
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
  YAML

  depends_on = [helm_release.argocd]  # ✅ Ensure ArgoCD is installed before applying app
}
