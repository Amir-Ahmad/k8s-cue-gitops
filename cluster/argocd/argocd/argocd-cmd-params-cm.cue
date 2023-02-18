package kube

kustomize: "argocd-cmd-params-cm": {
	filename: "argocd-cmd-params-cm.cue.yaml"
	content:  k8s.#ConfigMap & {
		metadata: name:          "argocd-cmd-params-cm"
		data: "server.insecure": "true"
	}
}
