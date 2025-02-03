################################################################################
# TERRAFORM MAIN CONFIGURATION FILE
################################################################################

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.eks_cluster_id
}

module "eks" {
  source          = "./modules/eks"
  aws_region      = var.aws_region
  # cluster_name    = var.eks_cluster_name
  vpc_cidr        = var.vpc_cidr
  subnet_count    = var.subnet_count
  node_min_size   = var.node_min_size
  node_max_size   = var.node_max_size
  node_desired_size = var.node_desired_size
  instance_types  = var.instance_types
}

# module "argocd" {
#   source = "./modules/argocd"

#   namespace     = var.argocd_namespace
#   argocd_version = var.argocd_version
#   app_name      = var.argocd_app_name
#   repo_url      = var.argocd_repo_url
#   app_path      = var.argocd_app_path

#   depends_on = [module.eks]
# }

# module "efk" {
#   source    = "./modules/efk"
#   depends_on = [module.eks]
# }

# module "argocd" {
#   source    = "./modules/argocd"
#   depends_on = [module.eks]
# }

# module "alb_ingress" {
#   source              = "./modules/alb_ingress"
#   eks_cluster_name    = var.eks_cluster_name
#   domain_name         = var.domain_name
#   ssl_certificate_arn = var.ssl_certificate_arn
#   hosted_zone_id      = var.hosted_zone_id
# }

# module "route53" {
#   source                  = "./modules/route53"
#   domain_name             = var.domain_name
#   hosted_zone_id          = var.hosted_zone_id
#   ingress_nginx_hostname  = module.nginx_ingress.ingress_nginx_hostname  # ✅ Use correct output
#   ingress_nginx_zone_id   = module.nginx_ingress.ingress_nginx_zone_id  # ✅ Use correct output
# }


# module "nginx_ingress" {
#   source         = "./modules/ingress"
#   domain_name    = var.domain_name
#   hosted_zone_id = var.hosted_zone_id  
# }







