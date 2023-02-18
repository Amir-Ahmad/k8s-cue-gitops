package abstractions

import (
	"crypto/sha256"
	"encoding/json"
	"encoding/base64"
	c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

_#deployment: k8s.#Deployment & {
	metadata:       k8s.#Metadata
	config=_config: c.#AppConfig
	_labels: {...}

	metadata: {
		labels: _labels
	}

	spec: {
		replicas: config.replicas
		selector: matchLabels: _labels
		strategy: config.strategy
	}

	spec: template: {
		metadata: {
			labels: _labels
			// Add checksum annotations to ensure pods are rolled when configmap or secrets change
			if config.configmap.rollOnChange == true {
				let sum = base64.Encode(null, sha256.Sum256(json.Marshal(config.configmap.data)))
				annotations: "config/checksum": sum
			}
			if config.secret.rollOnChange == true {
				let sum = base64.Encode(null, sha256.Sum256(json.Marshal(config.secret.stringData)))
				annotations: "secret/checksum": sum
			}
		}
		_#podSpec & {_config: config}
	}
}
