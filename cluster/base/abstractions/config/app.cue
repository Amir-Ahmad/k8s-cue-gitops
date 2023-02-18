package config

import (
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

#AppConfig: X={
	name:      string
	namespace: string
	instance:  string | *name

	metadata: #Metadata

	#PodConfig & {
		containerName: string | *X.name
	}

	type: *"deployment" | "statefulset" | "daemonset"

	if type == "deployment" {
		replicas: int | *1

		strategy: {
			type:           "Recreate" | *"RollingUpdate"
			rollingUpdate?: k8s.#RollingUpdateDeployment
		}
	}
	if type == "daemonset" {
		strategy: {
			type:           *"RollingUpdate" | "OnDelete"
			rollingUpdate?: k8s.#RollingUpdateDaemonSet
		}
	}
	statefulsetSpec?: {...}
	if type == "statefulset" {
		replicas: int | *1
		strategy: {
			type:           *"RollingUpdate" | "OnDelete"
			rollingUpdate?: k8s.#RollingUpdateStatefulSet
		}
		statefulsetSpec: {
			serviceName:         string | *X.name
			podManagementPolicy: *"OrderedReady" | "Parallel"
			volumeClaimTemplates: [...k8s.#PersistentVolumeClaim]
		}
	}

	configmap: {
		enabled:      bool | *false
		rollOnChange: bool | *false
		data: {...}
	}

	secret: {
		enabled:      bool | *false
		rollOnChange: bool | *false
		stringData: {...}
	}

	pvc: {
		enabled:     bool | *false
		accessModes: [...string] | *["ReadWriteOnce"]

		if enabled == true {
			storageClassName: string
			storage:          string
		}
	}

	ingress: #IngressConfig & {
		enabled: bool | *false
	}
}
