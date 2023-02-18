package kube

kustomize: "metrics-server-values": {
	filename: "values.cue.yaml"
	content:  values
}

let values = {
	args: [
		"--kubelet-insecure-tls",
	]
}
