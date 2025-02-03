################################################################################
# TERRAFORM EFK MODULE OUTPUTS FILE
################################################################################

output "elasticsearch_endpoint" {
  description = "Elasticsearch internal endpoint"
  value       = "http://${helm_release.elasticsearch.name}-master.${var.namespace}.svc.cluster.local:9200"
}

output "fluentd_pv" {
  description = "Persistent Volumes used by Fluentd"
  value       = "kubectl get pv -n ${var.namespace}"
}

output "kibana_endpoint" {
  description = "Kibana internal URL"
  value       = "http://kibana.${var.namespace}.svc.cluster.local:5601"
}
