package kube

kustomize: "victoria-metrics-values": {
	filename: "values.cue.yaml"
	content:  values
}

let values = {
	server: {
		persistentVolume: {
			enabled:       true
			existingClaim: "victoria-metrics"
		}
		// Data retention period in months
		retentionPeriod: 2
	}

	server: scrape: {
		enabled:   true
		configMap: ""
		config: {
			global: scrape_interval: "15s"
			scrape_configs: [{
				job_name: "victoriametrics"
				static_configs: [{
					targets: ["localhost:8428"]}]
			}, {
				job_name: "node-exporter"
				static_configs: [{
					targets: ["prometheus-node-exporter.monitoring.svc.cluster.local:9100"]}]
			}, {
				job_name: "kubernetes-apiservers"
				kubernetes_sd_configs: [{
					role: "endpoints"
				}]
				scheme: "https"
				tls_config: {
					ca_file:              "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
					insecure_skip_verify: true
				}
				bearer_token_file: "/var/run/secrets/kubernetes.io/serviceaccount/token"
				relabel_configs: [{
					source_labels: [
						"__meta_kubernetes_namespace",
						"__meta_kubernetes_service_name",
						"__meta_kubernetes_endpoint_port_name",
					]

					action: "keep"
					regex:  "default;kubernetes;https"
				}]
			}, {
				job_name: "kubernetes-nodes"
				scheme:   "https"
				tls_config: {
					ca_file:              "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
					insecure_skip_verify: true
				}
				bearer_token_file: "/var/run/secrets/kubernetes.io/serviceaccount/token"
				kubernetes_sd_configs: [{
					role: "node"
				}]
				relabel_configs: [{
					action: "labelmap"
					regex:  "__meta_kubernetes_node_label_(.+)"
				}, {
					target_label: "__address__"
					replacement:  "kubernetes.default.svc:443"
				}, {
					source_labels: ["__meta_kubernetes_node_name"]
					regex:        "(.+)"
					target_label: "__metrics_path__"
					replacement:  "/api/v1/nodes/$1/proxy/metrics"
				}]
			}, {
				job_name: "kubernetes-nodes-cadvisor"
				scheme:   "https"
				tls_config: {
					ca_file:              "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
					insecure_skip_verify: true
				}
				bearer_token_file: "/var/run/secrets/kubernetes.io/serviceaccount/token"
				kubernetes_sd_configs: [{
					role: "node"
				}]
				relabel_configs: [{
					action: "labelmap"
					regex:  "__meta_kubernetes_node_label_(.+)"
				}, {
					target_label: "__address__"
					replacement:  "kubernetes.default.svc:443"
				}, {
					source_labels: ["__meta_kubernetes_node_name"]
					regex:        "(.+)"
					target_label: "__metrics_path__"
					replacement:  "/api/v1/nodes/$1/proxy/metrics/cadvisor"
				}]
				metric_relabel_configs: [{
					action: "replace"
					source_labels: ["pod"]
					regex:        "(.+)"
					target_label: "pod_name"
					replacement:  "${1}"
				}, {
					action: "replace"
					source_labels: ["container"]
					regex:        "(.+)"
					target_label: "container_name"
					replacement:  "${1}"
				}, {
					action:       "replace"
					target_label: "name"
					replacement:  "k8s_stub"
				}, {
					action: "replace"
					source_labels: ["id"]
					regex:        "^/system\\.slice/(.+)\\.service$"
					target_label: "systemd_service_name"
					replacement:  "${1}"
				}]
			}]
		}
	}
}
