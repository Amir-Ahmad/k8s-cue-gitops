package kube

_ingressCommon: {
	auth:            string | *"authelia"
	enabled:         true
	domainName:      globals.domainName
	servicePortName: string | *"http"
}
