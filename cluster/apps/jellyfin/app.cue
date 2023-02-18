package kube

apps: jellyfin: X={
	namespace: "media"
	image:     "docker.io/jellyfin/jellyfin:10.8.3"

	ports: http: port: 8096

	volumes: {
		media: {
			spec: hostPath: {
				path: "\(globals.downloadsPath)/media"
				type: "Directory"
			}
			mounts: [{
				mountPath: "/media"
			}]
		}
		config: {
			spec: hostPath: {
				path: "\(globals.appsPath)/jellyfin"
				type: "DirectoryOrCreate"
			}
			mounts: [{
				mountPath: "/config"
			}]
		}
	}

	ingress: _ingressCommon & {
		auth: "disabled"
		host: "\(X.name).\(globals.domainName)"
	}

	resources: {
		limits: memory:   "5000Mi"
		requests: memory: "1000Mi"
	}
}
