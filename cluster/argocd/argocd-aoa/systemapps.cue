package kube

argoapp: authelia: _#systemApp & {
	type:     "cue"
	syncWave: -1
}
argoapp: "cert-manager": _#systemApp & {
	syncWave: -3
}
argoapp: "external-dns": _#systemApp & {
	syncWave: -3
}
argoapp: glauth: _#systemApp & {
	type:     "cue"
	syncWave: -2
}
argoapp: grafana:         _#systemApp
argoapp: "ingress-nginx": _#systemApp & {
	syncWave: -1
}
argoapp: "lvm-localpv": _#systemApp & {
	syncWave: -4
}
argoapp: "metrics-server": _#systemApp
argoapp: namespaces:       _#systemApp & {
	type: "cue"
	// Create namespaces first
	syncWave:      -5
	cascadeDelete: false
}
argoapp: "node-exporter":    _#systemApp
argoapp: "victoria-metrics": _#systemApp
