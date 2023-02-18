package kube

import "encoding/yaml"

_configmap_data: "configuration.yaml": yaml.Marshal(_config)

_config: {
	theme:                   "light"
	default_redirection_url: "https://www.\(globals.domainName)"
	default_2fa_method:      ""
	server: {
		host:       "0.0.0.0"
		port:       80
		asset_path: ""
		headers: csp_template: ""
		read_buffer_size:  4096
		write_buffer_size: 4096
		enable_pprof:      false
		enable_expvars:    false
	}
	log: {
		level:       "info"
		format:      "text"
		file_path:   ""
		keep_stdout: true
	}
	totp: {
		disable:     false
		issuer:      globals.domainName
		algorithm:   "sha1"
		digits:      6
		period:      30
		skew:        1
		secret_size: 32
	}
	webauthn: {
		disable:                           false
		display_name:                      "Authelia"
		attestation_conveyance_preference: "indirect"
		user_verification:                 "preferred"
		timeout:                           "60s"
	}
	ntp: {
		address:               "time.cloudflare.com:123"
		version:               4
		max_desync:            "3s"
		disable_startup_check: false
		disable_failure:       false
	}

	authentication_backend: {
		password_reset: {
			disable:    true
			custom_url: ""
		}
		ldap: {
			implementation:         "custom"
			url:                    "ldap://glauth.auth.svc.cluster.local:389"
			timeout:                "5s"
			start_tls:              false
			base_dn:                "\(globals.domainDn)"
			additional_users_dn:    "ou=users"
			users_filter:           "(&({username_attribute}={input})(objectClass=posixAccount))"
			username_attribute:     "uid"
			display_name_attribute: "uid"
			groups_filter:          "(&(memberUid={username})(objectClass=posixGroup))"
			group_name_attribute:   "cn"
			user:                   "CN=search,ou=svcaccts,\(globals.domainDn)"
		}
	}
	identity_providers: oidc: {
		clients: [{
			id:                              "argocd"
			description:                     "Argo CD"
			secret:                          _secrets.argocdClientSecretHash
			public:                          false
			authorization_policy:            "one_factor"
			pre_configured_consent_duration: "1y"
			scopes: ["openid", "profile", "groups", "email"]
			redirect_uris: ["https://argocd.\(globals.domainName)/auth/callback"]
			userinfo_signing_algorithm: "none"
		}, {
			id:                              "grafana"
			description:                     "Grafana"
			secret:                          _secrets.grafanaClientSecretHash
			public:                          false
			authorization_policy:            "one_factor"
			pre_configured_consent_duration: "1y"
			scopes: ["openid", "profile", "groups", "email"]
			redirect_uris: ["https://grafana.\(globals.domainName)/login/generic_oauth"]
			userinfo_signing_algorithm: "none"
		}]
	}

	password_policy: {
		standard: {
			enabled: false
		}
		zxcvbn: {
			enabled: false
		}
	}
	session: {
		name:                 "authelia_session"
		domain:               globals.domainName
		same_site:            "lax"
		expiration:           "1h"
		inactivity:           "5m"
		remember_me_duration: "1M"
	}
	regulation: {
		ban_time:    "5m"
		find_time:   "2m"
		max_retries: 5
	}
	storage: local: path: "/config/db.sqlite3"
	notifier: {
		disable_startup_check: false
		filesystem: filename: "/config/notification.txt"
	}
	access_control: {
		default_policy: "deny"
		rules:          _rules
	}
}
