package kube

_#app: {
	name:     string
	clusters: [...or(globals.allClusters)] | *globals.allClusters
	path:     string | *"apps/\(name)"
	repoUrl:  globals.repoUrl
	type:     "default" | "cue-kustomize" | *"cue"
	...
}

_#systemApp: {
	name:     string
	clusters: [...or(globals.allClusters)] | *globals.allClusters
	path:     string | *"system/\(name)"
	repoUrl:  globals.repoUrl
	type:     "default" | *"cue-kustomize" | "cue"
	...
}
