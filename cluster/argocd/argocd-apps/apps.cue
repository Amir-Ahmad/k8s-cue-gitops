package kube

argoapp: apps: {
	clusters:      globals.allClusters
	repoUrl:       globals.repoUrl
	path:          "argocd/argocd-aoa"
	type:          "cue"
	cascadeDelete: false
}
