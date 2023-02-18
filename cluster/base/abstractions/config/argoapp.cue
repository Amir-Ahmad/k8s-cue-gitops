package config

#ArgoAppConfig: {
	clusters: [...string]
	name: string
	// By convention Argocd applications are deployed to the argocd namespace
	namespace:         string | *"argocd"
	metadata:          #Metadata
	project:           string | *"default"
	destinationServer: string | *"https://kubernetes.default.svc"
	repoUrl:           string
	targetRevision:    string | *"main"
	// Path containing Application manifests, relative to cluster.
	path: string
	// Type of application
	// Default is for normal kustomize or kubernetes manifests. 
	type:            "default" | "cue-kustomize" | "cue"
	prune:           bool | *true
	selfHeal:        bool | *true
	cascadeDelete:   bool | *true
	createNamespace: bool | *false
	syncWave?:       int

	// List of environment variables.
	pluginEnv: [string]: string
}
