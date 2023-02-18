package abstractions

import (
	c "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/abstractions/config"
	k8s "github.com/amir-ahmad/k8s-cue-gitops/cluster/base/kubernetes"
)

_#service: k8s.#Service & {
	metadata: k8s.#Metadata
	_ports: [...c.#PortConfig]

	spec: ports: [ for x in _ports {
		name:       x.name
		port:       x.port
		targetPort: x.port
		protocol:   x.protocol
		if x.nodePort != _|_ {
			nodePort: x.nodePort
		}
	}]
}
