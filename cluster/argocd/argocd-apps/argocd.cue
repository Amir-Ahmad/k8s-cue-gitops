package kube

argoapp: "argocd": {
	clusters:      globals.allClusters
	repoUrl:       globals.repoUrl
	path:          "argocd/argocd"
	type:          "cue-kustomize"
	prune:         false
	cascadeDelete: false
}
