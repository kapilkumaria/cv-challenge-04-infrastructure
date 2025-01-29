output "elasticsearch_endpoint" {
  value = "http://elasticsearch-master.logging.svc.cluster.local:9200"
}

output "kibana_endpoint" {
  value = "http://kibana.logging.svc.cluster.local:5601"
}