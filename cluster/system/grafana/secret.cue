package kube

objects: secret: "grafana-secrets": {
	metadata: namespace: "monitoring"
	stringData: {
		adminUser: _secrets.adminUser
		adminPass: _secrets.adminPass
	}
}
