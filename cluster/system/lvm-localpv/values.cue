package kube

kustomize: "lvm-values": {
	filename: "values.cue.yaml"
	content:  values
}

let values = {
	rbac: pspEnabled: false
	lvmNode: {
		kubeletDir: "/var/lib/kubelet/"
	}
}
