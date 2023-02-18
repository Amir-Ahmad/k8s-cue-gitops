package abstractions

import (
	c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

#CronJob: X={
	config: c.#CronjobConfig

	metadata: X.config.metadata & {
		namespace: config.namespace
		name:      X.config.name
		labels: app: config.name
	}

	out: k8s.#CronJob & {
		metadata: X.metadata
		spec: schedule: config.schedule
		spec: jobTemplate: spec: template: _#podSpec & {_config: config}
	}
}
