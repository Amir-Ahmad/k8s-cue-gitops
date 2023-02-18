package kube

kustomize: "argocd-rbac-cm": {
	filename: "argocd-rbac-cm.cue.yaml"
	content:  k8s.#ConfigMap & {
		metadata: name: "argocd-rbac-cm"
		data: {
			"policy.default": ""
			"policy.csv": """
				g, admins, role:admin
				"""
		}
	}
}
