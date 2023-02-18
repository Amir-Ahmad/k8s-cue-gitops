package kube

import (
	"list"
	abstractions "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/objects:abstractions"
	abs_config "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"
	kubernetes "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
	c "github.com/amir-ahmad/k8s-cue-gitops/cluster/config"
)

// Set k8s object globally
k8s: kubernetes

globals: {
	cluster:     *"c0" | or([ for x, _ in c.clusters {x}]) @tag(cluster)
	allClusters: c.allClusters
	// Make cluster properties available under globals
	c.clusters[cluster]

	// Likewise for config.globals
	c.globals
}

// List of application configs
apps: [Name=_]: abs_config.#AppConfig & {
	name: string | *Name
}

abstracted_cronjob=cronjob: [Name=_]: abs_config.#CronjobConfig & {
	name: string | *Name
}

abstracted_ingress=ingress: [Name=_]: abs_config.#IngressConfigAbs & {
	name: string | *Name
}

abstracted_argoapp=argoapp: [Name=_]: abs_config.#ArgoAppConfig & {
	name: string | *Name
	clusters: [...or(c.allClusters)]
}

objects: {
	argoapp: [Name=_]: k8s.#ArgoApp & {
		metadata: name: string | *Name
	}
	certificate: [Name=_]: k8s.#Certificate & {
		metadata: name: string | *Name
	}
	clusterIssuer: [Name=_]: k8s.#ClusterIssuer & {
		metadata: name: string | *Name
	}
	configmap: [Name=_]: k8s.#ConfigMap & {
		metadata: name: string | *Name
	}
	cronjob: [Name=_]: k8s.#CronJob & {
		metadata: name: string | *Name
	}
	deployment: [Name=_]: k8s.#Deployment & {
		metadata: name: string | *Name
	}
	statefulset: [Name=_]: k8s.#StatefulSet & {
		metadata: name: string | *Name
	}
	daemonset: [Name=_]: k8s.#DaemonSet & {
		metadata: name: string | *Name
	}
	ingress: [Name=_]: k8s.#Ingress & {
		metadata: name: string | *Name
	}
	namespace: [Name=_]: k8s.#Namespace & {
		metadata: name: string | *Name
	}
	persistentVolumeClaim: [Name=_]: k8s.#PersistentVolumeClaim & {
		metadata: name: string | *Name
	}
	secret: [Name=_]: k8s.#Secret & {
		metadata: name: string | *Name
	}
	service: [Name=_]: k8s.#Service & {
		metadata: name: string | *Name
	}
	storageClass: [Name=_]: k8s.#StorageClass & {
		metadata: name: string | *Name
	}
}

// This section merges the abstracted config of apps/cronjob/etc, 
// converts to kubernetes objects, and places the objects into the main objects: <kind> list.
for k, v in abstracted_ingress {
	objects: ingress: "\(k)": (abstractions.#Ingress & {config: v}).out
}
for k, v in abstracted_cronjob {
	objects: cronjob: "\(k)": (abstractions.#CronJob & {config: v}).out
}
for k, v in abstracted_argoapp {
	// Only output argoapp if the current cluster matches
	if list.Contains(v.clusters, globals.cluster) {
		objects: argoapp: "\(k)": (abstractions.#ArgoApp & {config: v}).out
	}
}

// Add all application objects to main objects: struct
for k, v in apps {
	let appObjects = (abstractions.#Application & {config: v}).out
	for type, typeObjects in appObjects {
		for name, object in typeObjects {
			objects: "\(type)": "\(name)": object
		}
	}
}

kustomize: [Name=_]: abstractions.#Kustomize
