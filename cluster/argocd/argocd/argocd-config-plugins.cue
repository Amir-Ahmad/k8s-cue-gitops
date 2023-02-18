package kube

import "encoding/yaml"

objects: configmap: "argocd-config-plugins": {
	metadata: namespace: "argocd"
	data: {
		"cue.yaml":           yaml.Marshal(cue_plugin)
		"cue-kustomize.yaml": yaml.Marshal(kustomize_plugin)
	}
}

let decrypt_secrets = """
	# Find and decrypt any sops.cue files in the current dir and cluster config dir
	configDir="$(git rev-parse --show-toplevel)/cluster/config"
	while IFS= read -r -d '' file; do
		sops -d "${file}" > "${file%.cue}.unenc.cue"
	done < <(find . "$configDir" -maxdepth 1 -name '*.sops.cue' -print0)
	
	# Decrypt any additional sops files specified in DECRYPT_SOPS_FILES
	# DECRYPT_SOPS_FILES should be separated by colons and relative to repo root.
	while read -d: -r sopsFile; do
		filePath="$(git rev-parse --show-toplevel)/${sopsFile}"
		sops -d "${filePath}" > "${filePath%.cue}.unenc.cue"
	done <<< "${ARGOCD_ENV_DECRYPT_SOPS_FILES:+"${ARGOCD_ENV_DECRYPT_SOPS_FILES}:"}"
	"""

let cue_plugin = {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "ConfigManagementPlugin"
	metadata: name: "cue"
	spec: {
		version: "v1.0"
		discover: find: command: [
			"bash",
			"-c",
			"[[ -n ${ARGOCD_ENV_ENABLE_CUE_PLUGIN} ]] && find . -name '*.cue'",
		]
		init: command: [
			"bash",
			"-c",
			decrypt_secrets,
		]
		generate: command: [
			"bash",
			"-c",
			"cue -t kind=${ARGOCD_ENV_KIND_FILTER:-} -t cluster=\(globals.cluster) dump ${ARGOCD_ENV_DUMP_PATH:-.}",
		]
	}
}

let kustomize_plugin = {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "ConfigManagementPlugin"
	metadata: name: "cue-kustomize"
	spec: {
		version: "v1.0"
		discover: find: command: [
			"bash",
			"-c",
			"[[ -n ${ARGOCD_ENV_ENABLE_KUSTOMIZE_PLUGIN} ]] && find . -name 'kustomization.yaml'",
		]
		init: command: [
			"bash",
			"-c",
			decrypt_secrets,
		]
		generate: command: [
			"bash",
			"-c",
			"cue -t cluster=\(globals.cluster) kdump .",
		]
	}
}
