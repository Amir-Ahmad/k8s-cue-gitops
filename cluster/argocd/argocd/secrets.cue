package kube

objects: secret: "argocd-additional-secrets": {
	metadata: {
		namespace: "argocd"
		labels: "app.kubernetes.io/part-of": "argocd"
	}
	stringData: {
		"age.agekey":                 _secrets.ageKey
		"oidc.authelia.clientSecret": _secrets.autheliaClientSecret
	}
}

objects: secret: "repo-creds": {
	metadata: namespace: "argocd"
	metadata: labels: "argocd.argoproj.io/secret-type": "repository"
	stringData: {
		type:          "git"
		url:           "git@github.com:amir-ahmad/k8s-cue-gitops"
		sshPrivateKey: _secrets.sshPrivateKey
	}
}
