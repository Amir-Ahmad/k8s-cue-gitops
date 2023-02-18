package kube

kustomize: "node-exporter-values": {
	filename: "values.cue.yaml"
	content:  values
}

let values = {
	namespaceOverride: "monitoring"
	rbac: pspEnabled: false
	service: port:    9100
	extraArgs: [
		"--collector.filesystem.mount-points-exclude",
		"^/(dev|proc|sys|var/lib/kubelet/.+|run/k3s/containerd/.+)($|/)",
	]
}
