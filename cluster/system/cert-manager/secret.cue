package kube

objects: secret: "cloudflare-token-cm": {
	metadata: {
		name:      "cloudflare-token"
		namespace: "cert-manager"
	}
	stringData: {
		token: _secrets.cloudflareToken
	}
}
