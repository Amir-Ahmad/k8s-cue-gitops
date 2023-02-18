package abstractions

import c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"

#Ingress: X={
	config: c.#IngressConfigAbs

	metadata: X.config.metadata & {
		namespace: config.namespace
		name:      X.config.name
	}

	out: _#ingress & {
		_config:  X.config
		metadata: X.metadata
	}
}
