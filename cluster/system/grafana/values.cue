package kube

kustomize: "grafana-values": {
	filename: "values.cue.yaml"
	content:  values
}

let grafanaHost = "grafana.\(globals.domainName)"

let values = {
	replicas: 1

	admin: {
		existingSecret: "grafana-secrets"
		passwordKey:    "adminPass"
		userKey:        "adminUser"
	}

	datasources: "datasources.yaml": {
		apiVersion: 1
		datasources: [{
			name:                  "victoriametrics"
			type:                  "prometheus"
			orgId:                 1
			url:                   "http://victoria-metrics-victoria-metrics-single-server.monitoring.svc.cluster.local:8428"
			access:                "proxy"
			isDefault:             true
			updateIntervalSeconds: 10
			editable:              true
		}]
	}

	dashboardProviders: "dashboardproviders.yaml": {
		apiVersion: 1
		providers: [{
			name:            "default"
			orgId:           1
			folder:          ""
			type:            "file"
			disableDeletion: true
			editable:        true
			options: path: "/var/lib/grafana/dashboards/default"
		}]
	}

	dashboards: default: {
		victoriametrics: {
			gnetId:     10229
			revision:   22
			datasource: "victoriametrics"
		}
		kubernetes: {
			gnetId:     14205
			revision:   1
			datasource: "victoriametrics"
		}
		"node-exporter-full": {
			gnetId:     1860
			revision:   28
			datasource: "victoriametrics"
		}
	}

	deploymentStrategy: type: "Recreate"

	env: {
		GF_ANALYTICS_CHECK_FOR_UPDATES:     false
		GF_DATE_FORMATS_USE_BROWSER_LOCALE: true
		GF_SERVER_ROOT_URL:                 "https://\(grafanaHost)"
	}

	"grafana.ini": {
		auth: {
			signout_redirect_url: "https://auth.\(globals.domainName)/logout"
			oauth_auto_login:     true
		}
		"auth.generic_oauth": {
			enabled:               true
			name:                  "Authelia"
			client_id:             "grafana"
			client_secret:         _secrets.autheliaClientSecret
			scopes:                "openid profile email groups"
			empty_scopes:          false
			auth_url:              "https://auth.\(globals.domainName)/api/oidc/authorization"
			token_url:             "https://auth.\(globals.domainName)/api/oidc/token"
			api_url:               "https://auth.\(globals.domainName)/api/oidc/userinfo"
			login_attribute_path:  "preferred_username"
			groups_attribute_path: "groups"
			name_attribute_path:   "name"
			use_pkce:              true
		}
		"auth.generic_oauth.group_mapping": {
			role_attribute_path: """
				contains(groups[*], 'admins') && 'Admin' || contains(groups[*], 'grafana-readonly') && 'Viewer'

				"""
			org_id: 1
		}

		server: root_url: "https://\(grafanaHost)"
	}

	ingress: {
		enabled:          true
		ingressClassName: "nginx"
		annotations: {
			"nginx.ingress.kubernetes.io/force-ssl-redirect": "true"
		}
		hosts: [
			grafanaHost,
		]
		tls: [{
			hosts: [
				grafanaHost,
			]
		}]
	}

	persistence: enabled: false

	plugins: [
		"natel-discrete-panel",
		"grafana-piechart-panel",
		"vonage-status-panel",
		"grafana-clock-panel",
	]

	rbac: pspEnabled: false

	serviceMonitor: enabled: false

	sidecar: {
		dashboards: {
			enabled:         true
			labelValue:      "1"
			searchNamespace: "ALL"
		}
		datasources: {
			enabled:         true
			labelValue:      "1"
			searchNamespace: "ALL"
		}
		logLevel: "INFO"
	}
}
