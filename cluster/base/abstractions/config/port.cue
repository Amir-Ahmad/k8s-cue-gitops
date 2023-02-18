package config

#PortConfig: {
	name:     string
	port:     int
	protocol: string | *"TCP"
	// expose and serviceType are applicable for Applications only
	// expose=true creates a service for the port
	expose: bool | *true

	if expose == true {
		serviceType: *"ClusterIP" | "NodePort"

		if serviceType == "NodePort" {nodePort: int}
	}
}
