package kube

apps: "rclone-web": X={
	namespace: "media"
	image:     "rclone/rclone:1.61"

	ports: http: port: 80

	containerSecurityContext: {
		runAsUser:  568
		runAsGroup: 568
	}

	args: [
		"rcd",
		"--rc-web-gui",
		"--rc-addr",
		":80",
		"--rc-web-gui-no-open-browser",
		"--rc-no-auth",
		"--cache-dir",
		"/cache",
	]

	volumes: {
		config: {
			spec: hostPath: {
				path: "\(globals.appsPath)/\(X.name)"
				type: "DirectoryOrCreate"
			}
			mounts: [{
				mountPath: "/config"
			}]
		}
		downloads: {
			spec: hostPath: {
				path: "\(globals.downloadsPath)/amir"
				type: "Directory"
			}
			mounts: [{
				mountPath: "/data"
			}]
		}
		cache: {
			spec: hostPath: {
				path: "\(globals.appsPath)/\(X.name)-cache"
				type: "DirectoryOrCreate"
			}
			mounts: [{
				mountPath: "/cache"
			}]
		}
	}

	ingress: _ingressCommon & {
		host: "\(X.name).\(globals.domainName)"
	}

	resources: {
		limits: memory:   "750Mi"
		requests: memory: "100Mi"
	}

	initContainers: init: {
		image: "alpine:latest"
		command: [
			"/bin/sh",
			"-c",
			"chown 568:568 /config && chown 568:568 /cache",
		]
		volumeMounts: [{
			name:      "config"
			mountPath: "/config"
		}, {
			name:      "cache"
			mountPath: "/cache"
		}]
	}
}
