package kube

apps: flexget: X={
	namespace: "media"
	image:     "wiserain/flexget:3.2.8"

	env: {
		FG_LOG_LEVEL:    "info"
		FG_LOG_FILE:     "flexget.log"
		PUID:            "568"
		PGID:            "568"
		FG_WEBUI_PASSWD: _secrets.webuiPassword
	}

	ports: http: port: 5050

	volumes: {
		media: {
			spec: hostPath: {
				path: "\(globals.downloadsPath)/media"
				type: "Directory"
			}
			mounts: [{
				mountPath: "/downloads"
			}]
		}
		config: {
			spec: persistentVolumeClaim: claimName: X.name
			mounts: [{
				mountPath: "/config"
			}]
		}
	}

	ingress: _ingressCommon & {
		host: "\(X.name).\(globals.domainName)"
	}

	resources: {
		limits: memory:   "500Mi"
		requests: memory: "250Mi"
	}

	pvc: {
		enabled:          true
		storageClassName: "lvm-ext4"
		storage:          "3Gi"
	}
}
