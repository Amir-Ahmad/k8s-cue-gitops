package kube

import "strings"

kustomize: "ingress-nginx-values": {
	filename: "values.cue.yaml"
	content:  values
}

_defaultCertSecretName: strings.Replace(globals.domainName, ".", "-", -1) + "-tls"

let values = {
	controller: {
		kind:        "DaemonSet"
		hostNetwork: true
		hostPort: enabled: true
		dnsPolicy:            "ClusterFirstWithHostNet"
		reportNodeInternalIp: true
		replicaCount:         1
		service: enabled: false
		config: {
			"ssl-protocols":         "TLSv1.3 TLSv1.2"
			"proxy-body-size":       "100m"
			"use-forwarded-headers": "true"
		}
		metrics: {
			enabled: false
			serviceMonitor: enabled: false
		}
		extraArgs: "default-ssl-certificate": "ingress-nginx/" + _defaultCertSecretName
		resources: {
			requests: {
				memory: "100Mi"
				cpu:    "100m"
			}
			limits: memory: "1000Mi"
		}
	}
}
