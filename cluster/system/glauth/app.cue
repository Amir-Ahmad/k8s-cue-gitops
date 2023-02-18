package kube

apps: glauth: X={
	namespace: "auth"
	image:     "glauth/glauth:v2.1.0"
	ports: {
		http: port: 5555
		ldap: port: 389
	}
	volumes: {
		config: {
			spec: configMap: name: X.name
			mounts: [{
				mountPath: "/config/server.toml"
				subPath:   "server.toml"
				readOnly:  true
			}, {
				mountPath: "/config/groups.toml"
				subPath:   "groups.toml"
				readOnly:  true
			}]
		}
		secrets: {
			spec: secret: {
				secretName: X.name
			}
			mounts: [{
				mountPath: "/config/users.toml"
				subPath:   "users.toml"
				readOnly:  true
			}]
		}
	}

	command: ["/app/glauth", "-c", "/config/"]

	resources: limits: memory: "100Mi"

	secret: {
		enabled:      true
		rollOnChange: true
		stringData: {
			//users.toml is stored as a secret as it contains hashed passwords
			"users.toml": _userConfig
		}
	}

	configmap: {
		enabled:      true
		rollOnChange: true
		data: {
			"server.toml": _serverConfig
			"groups.toml": _groupConfig
		}
	}
}
