package abstractions

import (
	c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

#ArgoApp: X={
	config: c.#ArgoAppConfig

	metadata: X.config.metadata & {
		namespace: X.config.namespace
		name:      X.config.name
		if X.config.cascadeDelete == true {
			finalizers: ["resources-finalizer.argocd.argoproj.io"]
		}
		if config.syncWave != _|_ {
			annotations: "argocd.argoproj.io/sync-wave": "\(config.syncWave)"
		}
	}

	let pluginEnv = [
		if config.type == "cue" {
			{
				name:  "ENABLE_CUE_PLUGIN"
				value: "true"
			}
		},
		if config.type == "cue-kustomize" {
			{
				name:  "ENABLE_KUSTOMIZE_PLUGIN"
				value: "true"
			}
		},
		for k, v in config.pluginEnv {name: k, value: v},
	]

	out: k8s.#ArgoApp & {
		metadata: X.metadata
		spec: {
			project: config.project
			source: {
				path:           "cluster/\(config.path)"
				repoURL:        config.repoUrl
				targetRevision: config.targetRevision
				if len(pluginEnv) > 0 {
					plugin: env: pluginEnv
				}
			}
			destination: server: config.destinationServer
			syncPolicy: {
				if config.createNamespace == true {
					syncOptions: ["CreateNamespace=true"]
				}
				automated: {
					prune:    config.prune
					selfHeal: config.selfHeal
				}
			}
		}
	}
}
