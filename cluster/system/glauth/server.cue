package kube

_serverConfig: """
[ldap]
  enabled = true
  listen = "0.0.0.0:389"

[ldaps]
  enabled = false

[backend]
  datastore = "config"
  baseDN = "\(globals.domainDn)"
  nameformat = "cn"
  groupformat = "ou"

# Enable API
[api]
  enabled = true
  tls = false
  listen = "0.0.0.0:5555"
"""
