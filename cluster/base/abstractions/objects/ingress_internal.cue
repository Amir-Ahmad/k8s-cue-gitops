package abstractions

import (
	c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

// Simple ingress which expects 1 rule and 1 path
_#ingress: k8s.#Ingress & {
	metadata: k8s.#Metadata

	config=_config: c.#IngressConfig

	metadata: annotations: {
		"nginx.ingress.kubernetes.io/force-ssl-redirect": "true"
	}

	if config.backendProtocol != null {
		metadata: annotations: "nginx.ingress.kubernetes.io/backend-protocol": config.backendProtocol
	}

	if config.auth != "disabled" {
		metadata: annotations: {
			"nginx.ingress.kubernetes.io/auth-response-headers": "Remote-User,Remote-Name,Remote-Groups,Remote-Email"
			"nginx.ingress.kubernetes.io/auth-snippet":          "proxy_set_header X-Forwarded-Method $request_method;"
			"nginx.ingress.kubernetes.io/configuration-snippet": "proxy_set_header X-Forwarded-Method $request_method;"
		}
	}

	if config.auth == "authelia" {
		metadata: annotations: {
			"nginx.ingress.kubernetes.io/auth-signin": "https://auth.\(config.domainName)/"
			"nginx.ingress.kubernetes.io/auth-url":    "https://auth.\(config.domainName)/api/verify"
		}
	}

	if config.auth == "basic" {
		metadata: annotations: {
			"nginx.ingress.kubernetes.io/auth-url": "https://auth.\(config.domainName)/api/verify?auth=basic"
		}
	}

	spec: {
		ingressClassName: config.ingressClassName
		rules: [{
			host: config.host
			http: paths: [{
				backend: service: {
					name: config.serviceName
					port: name: config.servicePortName
				}
				path:     config.path
				pathType: config.pathType
			}]
		}]
		tls: [{
			hosts: [config.host]
			if config.secretName != null {
				secretName: config.secretName
			}
		}]
	}
}
