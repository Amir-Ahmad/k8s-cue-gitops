package kube

kustomize: "cert-manager-values": {
	filename: "values.cue.yaml"
	content:  values
}

let values = {
	installCRDs: true
	webhook: enabled: true
	extraArgs: [
		"--dns01-recursive-nameservers=1.1.1.1:53,9.9.9.9:53",
		"--dns01-recursive-nameservers-only",
	]
	replicaCount: 1
	podDnsPolicy: "None"
	podDnsConfig: nameservers: ["1.1.1.1", "9.9.9.9"]
	// Fix as per https://github.com/cert-manager/cert-manager/issues/3717#issuecomment-931567578
	global: leaderElection: namespace: "cert-manager"
}
