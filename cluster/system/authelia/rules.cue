package kube

_rules: [{
	domain: globals.domainName
	policy: "one_factor"
	subject: ["group:admins"]
}, {
	domain: "*.\(globals.domainName)"
	policy: "one_factor"
	subject: ["group:admins"]
}]
