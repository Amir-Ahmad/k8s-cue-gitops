package kube

let baseAcme = {
	server: string
	email:  globals.email
	privateKeySecretRef: name: string
	solvers: [{
		dns01: cloudflare: {
			email: globals.email
			apiTokenSecretRef: {
				name: "cloudflare-token"
				key:  "token"
			}
		}
		selector: dnsZones: [globals.domainName]
	}]
}

objects: clusterIssuer: "letsencrypt-production": spec: acme: baseAcme & {
	server: "https://acme-v02.api.letsencrypt.org/directory"
	privateKeySecretRef: name: "letsencrypt-production"
}

objects: clusterIssuer: "letsencrypt-staging": spec: acme: baseAcme & {
	server: "https://acme-staging-v02.api.letsencrypt.org/directory"
	privateKeySecretRef: name: "letsencrypt-staging"
}
