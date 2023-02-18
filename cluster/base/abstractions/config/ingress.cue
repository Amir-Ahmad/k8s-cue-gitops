package config

#IngressConfig: {
	auth:             "authelia" | "basic" | "disabled"
	ingressClassName: "nginx"
	domainName:       string | *null // for authelia auth.{domainName} annotation
	host:             string | *null // ingress host
	path:             string | *"/"
	pathType:         *"Prefix" | "Exact" | "ImplementationSpecific"
	backendProtocol:  *null | "HTTP" | "HTTPS" | "GRPC"
	serviceName:      string | *null
	servicePortName:  string | *null
	secretName:       string | *null
	... // Open to allow AppConfig to add enabled variable
}

#IngressConfigAbs: #IngressConfig & {
	name:      string
	namespace: string
	metadata:  #Metadata
}
