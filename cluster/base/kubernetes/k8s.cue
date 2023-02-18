package kubernetes

import (
	apps_v1 "k8s.io/api/apps/v1"
	core_v1 "k8s.io/api/core/v1"
	net_v1 "k8s.io/api/networking/v1"
	batch_v1 "k8s.io/api/batch/v1"
	storage_v1 "k8s.io/api/storage/v1"
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	cert_v1 "github.com/cert-manager/cert-manager/pkg/apis/certmanager/v1"
	argocd "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)

#Metadata: meta_v1.#ObjectMeta

#VolumeMount: core_v1.#VolumeMount

#Probe: core_v1.#Probe

#RollingUpdateDeployment:  apps_v1.#RollingUpdateDeployment
#RollingUpdateDaemonSet:   apps_v1.#RollingUpdateDaemonSet
#RollingUpdateStatefulSet: apps_v1.#RollingUpdateStatefulSetStrategy

#StatefulSet: apps_v1.#StatefulSet & {
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata:   #Metadata
}

#DaemonSet: apps_v1.#DaemonSet & {
	apiVersion: "apps/v1"
	kind:       "DaemonSet"
	metadata:   #Metadata
}

#Deployment: apps_v1.#Deployment & {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   #Metadata
}

#CronJob: batch_v1.#CronJob & {
	apiVersion: "batch/v1"
	kind:       "CronJob"
	metadata:   #Metadata
}

#Service: core_v1.#Service & {
	apiVersion: "v1"
	kind:       "Service"
	metadata:   #Metadata
}

#Ingress: net_v1.#Ingress & {
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata:   #Metadata
	spec:       net_v1.#IngressSpec
}

#ConfigMap: core_v1.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata:   #Metadata
}

#Secret: core_v1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata:   #Metadata
}

#StorageClass: storage_v1.#StorageClass & {
	apiVersion: "storage.k8s.io/v1"
	kind:       "StorageClass"
	metadata:   #Metadata
}

#Namespace: core_v1.#Namespace & {
	apiVersion: "v1"
	kind:       "Namespace"
	metadata:   #Metadata
}

#PersistentVolumeClaim: core_v1.#PersistentVolumeClaim & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
}

#Resources: core_v1.#ResourceRequirements

#EnvFromSource: core_v1.#EnvFromSource

#Certificate: cert_v1.#Certificate & {
	apiVersion: "cert-manager.io/v1"
	kind:       "Certificate"
}

#ClusterIssuer: cert_v1.#ClusterIssuer & {
	apiVersion: "cert-manager.io/v1"
	kind:       "ClusterIssuer"
}

#ArgoApp: argocd.#Application & {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
}

#K8sObject: {
	apiVersion: string
	kind:       string
	metadata:   #Metadata & {
		// Set name as mandatory field
		name: string
	}
	["spec" | "data" | "stringdata"]: _
}
