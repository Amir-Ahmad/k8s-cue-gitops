package config

import (
	"strings"
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

#PodConfig: {
	#ContainerConfig

	enableServiceLinks?: bool

	podSecurityContext?: _

	// restartPolicy is "Always", "Never", "OnFailure", 
	// but for CronJobs its just the last two
	restartPolicy?: _

	// List of initContainers
	initContainers: [Name=string]: #ContainerConfig & {containerName: Name}

	// List of volumes. These will be associated to the Pod,
	// and mounted to the primary container if mounts are provided.
	volumes: [Name=_]: {
		name: string | *Name
		mounts: [...k8s.#VolumeMount & {name: Name}]
		spec: {...}
	}
}

#ContainerConfig: {
	containerName?:  string
	image:           string
	imagePullPolicy: "IfNotPresent" | "Always" | "Never"
	if image != _|_ {
		if strings.HasSuffix(image, ":latest") == true {
			imagePullPolicy: "IfNotPresent" | *"Always" | "Never"
		}
		if strings.HasSuffix(image, ":latest") != true {
			imagePullPolicy: *"IfNotPresent" | "Always" | "Never"
		}
	}

	// Container command and args
	command: [...string]
	args: [...string]

	// List of environment variables.
	env: [string]: string

	// Set container environment variables from configmap or secret
	envFrom: [...k8s.#EnvFromSource]

	// Resources requirements / limits
	resources?: k8s.#Resources

	// List of volume mounts
	volumeMounts: [...k8s.#VolumeMount]

	// List of ports on the app
	ports: [Name=_]: #PortConfig & {name: Name}

	containerSecurityContext?: _

	// Add probes
	livenessProbe:  _#probe
	readinessProbe: _#probe
	startupProbe:   _#probe
}

_#probe: {
	enabled: bool | *false
	spec:    k8s.#Probe
}
