package kube

import "encoding/yaml"

kustomize: "argocd-cm": {
	filename: "argocd-cm.cue.yaml"
	content:  k8s.#ConfigMap & {
		metadata: name: "argocd-cm"
		data: {
			"oidc.config": yaml.Marshal({
				name:         "Authelia"
				issuer:       "https://auth.\(globals.domainName)"
				clientID:     "argocd"
				clientSecret: "$argocd-additional-secrets:oidc.authelia.clientSecret"
				requestedScopes: ["openid", "profile", "email", "groups"]
			})
			url: "https://argocd.\(globals.domainName)"
		}
	}
}
