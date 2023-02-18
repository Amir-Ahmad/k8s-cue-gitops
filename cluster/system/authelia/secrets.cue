package kube

_secret_data: {
	JWT_TOKEN:              _secrets.jwtToken
	SESSION_ENCRYPTION_KEY: _secrets.sessionKey
	STORAGE_ENCRYPTION_KEY: _secrets.storageKey
	LDAP_PASSWORD:          _secrets.ldapSvcPassword
	ISSUER_PRIVATE_KEY:     _secrets.issuerPrivateKey
}
