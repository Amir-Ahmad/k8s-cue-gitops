package kube

objects: secret: "cloudflare-token-extdns": {
	metadata: {
		name:      "cloudflare-token"
		namespace: "external-dns"
	}
	stringData: {
		token: _secrets.cloudflareToken
	}
}
