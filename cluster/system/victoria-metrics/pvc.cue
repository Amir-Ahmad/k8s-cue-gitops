package kube

objects: persistentVolumeClaim: "victoria-metrics": {
	metadata: namespace: "monitoring"
	spec: {
		accessModes: [
			"ReadWriteOnce",
		]
		resources: requests: storage: "15Gi"
		storageClassName: "lvm-ext4"
	}
}
