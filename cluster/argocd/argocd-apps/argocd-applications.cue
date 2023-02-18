package kube

argoapp: "argocd-applications": {
	clusters:      globals.allClusters
	repoUrl:       globals.repoUrl
	path:          "argocd/argocd-apps"
	type:          "cue"
	prune:         false
	cascadeDelete: false
}
