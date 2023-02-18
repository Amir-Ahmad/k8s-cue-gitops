package abstractions

import (
	c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

// An Application creates the following resources
// Deployment
// Service (If ports are defined and exposed)
// Ingress (optional)
// ConfigMap (optional)
#Application: X={
	config: c.#AppConfig

	labels: {
		app:      config.name
		instance: config.instance
	}

	metadata: {
		namespace: config.namespace
		name:      string | *config.name
		labels:    X.labels
	}

	if config.type == "deployment" {
		out: deployment: "\(metadata.name)": _#deployment & {
			_config:  config
			_labels:  labels
			metadata: X.metadata
		}
	}
	if config.type == "daemonset" {
		out: daemonset: "\(metadata.name)": _#daemonset & {
			_config:  config
			_labels:  labels
			metadata: X.metadata
		}
	}
	if config.type == "statefulset" {
		out: statefulset: "\(metadata.name)": _#statefulset & {
			_config:  config
			_labels:  labels
			metadata: X.metadata
		}
	}

	if config.ingress.enabled == true {
		_ingressConfig: config.ingress
		if _ingressConfig.serviceName == null {
			_ingressConfig: serviceName: config.name
		}

		out: ingress: "\(metadata.name)": _#ingress & {
			_config:  _ingressConfig
			metadata: X.metadata
		}
	}

	// Create configmap if enabled
	if config.configmap.enabled == true {
		out: configmap: "\(metadata.name)": k8s.#ConfigMap & {
			metadata: X.metadata
			data:     config.configmap.data
		}
	}

	// Create secret if enabled
	if config.secret.enabled == true {
		out: secret: "\(metadata.name)": k8s.#Secret & {
			metadata:   X.metadata
			stringData: config.secret.stringData
		}
	}

	// Create PVC if enabled
	if config.pvc.enabled == true {
		out: persistentVolumeClaim: "\(metadata.name)": k8s.#PersistentVolumeClaim & {
			metadata: X.metadata
			spec: {
				accessModes: config.pvc.accessModes
				resources: requests: storage: config.pvc.storage
				storageClassName: config.pvc.storageClassName
			}
		}
	}

	let clusterIpPorts = [ for port in config.ports if port.expose == true && port.serviceType == "ClusterIP" {port}]
	let nodePorts = [ for port in config.ports if port.expose == true && port.serviceType == "NodePort" {port}]

	// Create ClusterIP service
	if len(clusterIpPorts) > 0 {
		out: service: "\(metadata.name)": _#service & {
			metadata: X.metadata
			_ports:   clusterIpPorts
			spec: type:     "ClusterIP"
			spec: selector: labels
		}
	}

	// Create nodeport service
	if len(nodePorts) > 0 {
		out: service: "\(metadata.name)-nodeport": _#service & {
			metadata: X.metadata & {name: "\(config.name)-nodeport"}
			_ports:   nodePorts
			spec: type:     "NodePort"
			spec: selector: labels
		}
	}
}
