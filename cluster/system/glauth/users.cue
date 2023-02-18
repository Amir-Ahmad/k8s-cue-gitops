package kube

_users: {
	// admin
	amir: {
		primarygroup: 2000
		uidnumber:    2000
		search:       true
		mail:         globals.email
	}
	// svcaccts
	search: {
		primarygroup: 2001
		search:       true
	}
}
