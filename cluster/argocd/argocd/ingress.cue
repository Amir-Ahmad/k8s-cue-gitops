package kube

ingress: "argocd-server-grpc": {
	namespace:       "argocd"
	auth:            "disabled"
	domainName:      globals.domainName
	host:            "argocd-grpc.\(globals.domainName)"
	serviceName:     "argocd-server"
	servicePortName: "https"
	backendProtocol: "GRPC"
	secretName:      "argocd-server-tls"
}

ingress: "argocd-server-http": {
	namespace:       "argocd"
	auth:            "disabled"
	domainName:      globals.domainName
	host:            "argocd.\(globals.domainName)"
	serviceName:     "argocd-server"
	servicePortName: "http"
	secretName:      "argocd-server-tls"
}
