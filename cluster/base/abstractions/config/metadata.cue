package config

import (
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

#Metadata: k8s.#Metadata & {
	// Set name to be mandatory
	name: string
}
