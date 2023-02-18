package kube

// Argocd certificate is placed here to prevent issues with bootstrapping cluster
objects: certificate: "argocd-certificate": {
	metadata: namespace: "argocd"
	spec: {
		secretName: "argocd-server-tls"
		issuerRef: {
			name: "letsencrypt-production"
			kind: "ClusterIssuer"
		}
		commonName: globals.domainName
		dnsNames: [
			globals.domainName,
			"argocd.\(globals.domainName)",
			"argocd-grpc.\(globals.domainName)",
		]
	}
}
