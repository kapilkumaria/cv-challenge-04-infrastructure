resource "kubectl_manifest" "argocd_app" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: adservice-app  # ✅ Name of the application in ArgoCD
  namespace: argocd
spec:
  project: default  # ✅ Use ArgoCD's default project (modify if using a different one)
  destination:
    namespace: default  # ✅ Namespace where adservice should be deployed
    server: https://kubernetes.default.svc
  source:
    repoURL: "https://github.com/kapilkumaria/cv-challenge-04-kubernetes.git"
    path: "apps/adservice"  # ✅ Path where adservice YAML files are stored
    targetRevision: main  # ✅ Deploy from the "main" branch
  syncPolicy:
    automated:
      prune: true  # ✅ Automatically delete removed manifests
      selfHeal: true  # ✅ Automatically sync changes from the repo
    syncOptions:
      - CreateNamespace=true  # ✅ Ensure namespace is created if not exists
  YAML

  depends_on = [helm_release.argocd]  # ✅ Ensure ArgoCD is installed before applying this
}
