package kube

import (
	"tool/file"
	"tool/exec"
	"tool/cli"
	"encoding/yaml"
	"strings"
)

_data: {
	// optionally allow filtering by cue -t kind=<kind> dump
	kind: *"" | string @tag(kind)
	outObjects: [...{}]

	outObjects: [
		for type in objects
		for object in type
		if kind == "" || (kind != "" && object.kind =~ "(?i)\(kind)") {object},
	]
}

// Output objects as yaml
command: dump: {
	task: print: cli.Print & {
		text: yaml.MarshalStream(_data.outObjects)
	}
}

// This command creates yaml files for kustomize, does a kustomize build, and cleans up
// It also does a normal dump for any other objects in the path
command: kdump: {
	// Create yaml files for kustomize
	for x in kustomize {
		"write-\(x.filename)": file.Create & {
			filename: x.filename
			contents: yaml.Marshal(x.content)
		}
	}

	// Run kustomize build
	kdump: exec.Run & {
		cmd: "kustomize build --enable-helm ."
	}

	// Clean up temporarily created files
	let filenames = strings.Join([ for x in kustomize {x.filename}], " ")
	if filenames != "" {
		clean: exec.Run & {
			$after: kdump
			cmd:    "rm \(filenames)"
		}
	}

	// Dump any other objects
	if len(_data.outObjects) > 0 {
		dump: cli.Print & {
			$after: kdump
			text:   "---\n" + yaml.MarshalStream(_data.outObjects)
		}
	}
}
