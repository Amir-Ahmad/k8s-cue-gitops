package abstractions

import c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"

_#container: {
	// Input config is a #ContainerConfig or superset of it (e.g. #AppConfig, #CronjobConfig)
	config=_config: {c.#ContainerConfig, ...}

	name:  config.containerName
	image: config.image

	imagePullPolicy: config.imagePullPolicy

	if len(config.command) > 0 {
		command: config.command
	}

	if len(config.args) > 0 {
		args: config.args
	}

	if len(config.ports) > 0 {
		ports: [ for k, v in config.ports {
			name:          k
			containerPort: v.port
			protocol:      v.protocol
		}]
	}

	if config.containerSecurityContext != _|_ {
		securityContext: config.containerSecurityContext
	}

	if len(config.envFrom) > 0 {
		envFrom: config.envFrom
	}

	env: [
		{
			name:  "TZ"
			value: "Australia/Sydney"
		},
		for k, v in config.env {name: k, value: v},
	]

	if len(config.volumeMounts) > 0 {
		volumeMounts: config.volumeMounts
	}

	if config.resources != _|_ {
		resources: config.resources
	}

	// Add probes
	if config.livenessProbe.enabled == true {
		livenessProbe: config.livenessProbe.spec
	}
	if config.readinessProbe.enabled == true {
		readinessProbe: config.readinessProbe.spec
	}
	if config.startupProbe.enabled == true {
		startupProbe: config.startupProbe.spec
	}

}

_#podSpec: {
	// Input config is a #PodConfig or superset of it (e.g. #AppConfig, #CronjobConfig)
	config=_config: {c.#PodConfig, ...}

	if config.enableServiceLinks != _|_ {
		spec: enableServiceLinks: config.enableServiceLinks
	}

	if config.podSecurityContext != _|_ {
		spec: securityContext: config.podSecurityContext
	}

	if config.restartPolicy != _|_ {
		spec: restartPolicy: config.restartPolicy
	}

	spec: containers: [{
		_#container & {
			_config: config & {
				volumeMounts: [ for v in config.volumes for m in v.mounts {m}]
			}
		}
	}]

	if len(config.initContainers) > 0 {
		spec: initContainers: [ for _, v in config.initContainers {
			_#container & {_config: v}
		}]
	}

	if len(config.volumes) > 0 {
		spec: volumes: [ for k, v in config.volumes {
			name: k
			v.spec
		}]
	}
}
