package kube

kustomize: "argocd-repo-server": {
	filename: "argocd-repo-server.cue.yaml"
	content:  k8s.#Deployment & {
		metadata: name: "argocd-repo-server"
		spec: template: spec: repoServerSpec
	}
}

let repoServerSpec = {
	// 1. Define an emptyDir volume which will hold the custom binaries
	volumes: [{
		name: "custom-tools"
		emptyDir: {}
	}, {
		name: "sops-age"
		secret: secretName: "argocd-additional-secrets"
	}, {
		name: "config-plugins"
		configMap: name: "argocd-config-plugins"
	}]
	// 2. Use an init container to download/copy custom binaries into the emptyDir
	initContainers: [{
		name:  "download-tools"
		image: "alpine:3.16"
		command: ["sh", "-ec"]
		env: [{
			name:  "SOPS_VERSION"
			value: "v3.7.3"
		}, {
			name:  "CUE_VERSION"
			value: "v0.4.3"
		}, {
			name:  "KUSTOMIZE_VERSION"
			value: "v4.5.7"
		}, {
			name:  "HELM_VERSION"
			value: "v3.10.1"
		}]
		args: [
			"""
				echo "Downloading sops"
				wget -qO /custom-tools/sops https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux

				echo "Downloading cue"
				wget -qO- https://github.com/cue-lang/cue/releases/download/v0.4.3/cue_${CUE_VERSION}_linux_amd64.tar.gz | tar xvz cue -C /custom-tools/

				echo "Downloading kustomize"
				wget -qO- https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz | tar xvz kustomize -C /custom-tools/

				echo "Downloading helm"
				wget -qO- https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xvz linux-amd64/helm -C /custom-tools/ \\
				  && mv /custom-tools/linux-amd64/helm /custom-tools/helm \\
				  && rm -rf /custom-tools/linux-amd64/

				chmod +x /custom-tools/*
				ls /custom-tools/
				""",
		]
		volumeMounts: [{
			mountPath: "/custom-tools"
			name:      "custom-tools"
		}]
	}]
	containers: [
		pluginContainer & {
			name:         "cue-plugin"
			volumeMounts: pluginMounts + [{
				mountPath: "/home/argocd/cmp-server/config/plugin.yaml"
				subPath:   "cue.yaml"
				name:      "config-plugins"
			}]
		},
		pluginContainer & {
			name:         "cue-kustomize-plugin"
			volumeMounts: pluginMounts + [{
				mountPath: "/home/argocd/cmp-server/config/plugin.yaml"
				subPath:   "cue-kustomize.yaml"
				name:      "config-plugins"
			}, {
				mountPath: "/usr/local/bin/helm"
				name:      "custom-tools"
				subPath:   "helm"
			}, {
				mountPath: "/usr/local/bin/kustomize"
				name:      "custom-tools"
				subPath:   "kustomize"
			}]
		},
	]
}

let pluginContainer = {
	name: string
	command: ["/var/run/argocd/argocd-cmp-server"]
	// use bitnami's minimal git image which has bash included
	image: "bitnami/git:2-debian-11"
	securityContext: {
		runAsNonRoot: true
		runAsUser:    999
	}
	resources: {
		limits: memory: "500Mi"
		requests: cpu:  "100m"
	}
	env: [{
		name:  "SOPS_AGE_KEY_FILE"
		value: "/sops-age/key"
	}]
	volumeMounts: [...]
}

let pluginMounts = [{
	mountPath: "/var/run/argocd"
	name:      "var-files"
}, {
	mountPath: "/home/argocd/cmp-server/plugins"
	name:      "plugins"
}, {
	mountPath: "/usr/local/bin/sops"
	name:      "custom-tools"
	subPath:   "sops"
}, {
	mountPath: "/usr/local/bin/cue"
	name:      "custom-tools"
	subPath:   "cue"
}, {
	mountPath: "/sops-age/key"
	name:      "sops-age"
	subPath:   "age.agekey"
}]
