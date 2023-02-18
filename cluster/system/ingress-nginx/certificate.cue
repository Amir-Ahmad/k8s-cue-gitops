package kube

objects: certificate: "wildcard-certificate": {
	metadata: namespace: "ingress-nginx"
	spec: {
		secretName: _defaultCertSecretName
		issuerRef: {
			name: "letsencrypt-production"
			kind: "ClusterIssuer"
		}
		commonName: globals.domainName
		dnsNames: [
			globals.domainName,
			"*.\(globals.domainName)",
		]
	}
}
