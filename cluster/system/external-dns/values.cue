package kube

kustomize: "external-dns-values": {
	filename: "values.cue.yaml"
	content:  values
}

let values = {
	interval: "5m"
	logLevel: "info"
	provider: "cloudflare"
	env: [{
		name: "CF_API_TOKEN"
		valueFrom: secretKeyRef: {
			name: "cloudflare-token"
			key:  "token"
		}
	}]
	extraArgs: [
		"--annotation-filter=external-dns/is-public in (true)",
		"--zone-id-filter=\(_secrets.cloudflareZoneId)",
	]
	sources: [
		"ingress",
	]
	// disabling sync as it deletes records from other cluster
	// policy: "sync"
	txtPrefix:  "k8s."
	txtOwnerId: "default"
}
