package kube

apps: authelia: X={
	namespace: "auth"
	image:     "ghcr.io/authelia/authelia:4.37.2"

	type:               "statefulset"
	enableServiceLinks: false
	statefulsetSpec: podManagementPolicy: "Parallel"
	ports: http: port: 80

	env: {
		AUTHELIA_SERVER_DISABLE_HEALTHCHECK:                      "true"
		AUTHELIA_JWT_SECRET_FILE:                                 "/secrets/JWT_TOKEN"
		AUTHELIA_SESSION_SECRET_FILE:                             "/secrets/SESSION_ENCRYPTION_KEY"
		AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE:                     "/secrets/STORAGE_ENCRYPTION_KEY"
		AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE:       "/secrets/LDAP_PASSWORD"
		AUTHELIA_IDENTITY_PROVIDERS_OIDC_ISSUER_PRIVATE_KEY_FILE: "/secrets/ISSUER_PRIVATE_KEY"
	}

	command: ["authelia"]
	args: ["--config=/configuration.yaml"]

	ingress: {
		enabled:         true
		auth:            "disabled"
		domainName:      globals.domainName
		host:            "auth.\(globals.domainName)"
		servicePortName: "http"
		secretName:      "local-tls"
	}

	configmap: {
		enabled: true
		data:    _configmap_data
	}

	let probe = {
		failureThreshold: 5
		httpGet: {
			path:   "/api/health"
			port:   "http"
			scheme: "HTTP"
		}
		initialDelaySeconds: int | *0
		periodSeconds:       int | *5
		successThreshold:    1
		timeoutSeconds:      5
	}

	livenessProbe: {
		enabled: true
		spec:    probe & {
			periodSeconds: 30
		}
	}
	readinessProbe: {
		enabled: true
		spec:    probe
	}
	startupProbe: {
		enabled: true
		spec:    probe & {
			initialDelaySeconds: 10
		}
	}

	resources: limits: memory: "100Mi"

	configmap: {
		enabled:      true
		rollOnChange: true
		data:         _configmap_data
	}

	secret: {
		enabled:      true
		rollOnChange: true
		stringData:   _secret_data
	}

	volumes: {
		config: {
			spec: configMap: {
				name: X.name
				items: [{
					key:  "configuration.yaml"
					path: "configuration.yaml"
				}]
			}
			mounts: [{
				mountPath: "/configuration.yaml"
				subPath:   "configuration.yaml"
				readOnly:  true
			}]
		}
		secrets: {
			spec: secret: {
				secretName: X.name
			}
			mounts: [{
				mountPath: "/secrets"
				readOnly:  true
			}]
		}
	}
}
