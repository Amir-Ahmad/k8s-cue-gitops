package config

_#Cluster: {
	name:          string
	domainName:    string
	domainDn:      string // Domain LDAP DN
	appsPath:      string
	downloadsPath: string
}

clusters: [X=string]: _#Cluster & {name: X}

clusters: "c0": {}

allClusters: [ for x, _ in clusters {x}]
