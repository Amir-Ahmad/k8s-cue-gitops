package kube

import "text/template"

_#user: {
	name:         string
	uidnumber:    int
	primarygroup: int
	passbcrypt:   string
	search:       bool | *false
	mail:         string | *null
}

_users: [Name=_]: _#user & {
	name: Name
}

let usersList = [ for x in _users {x}]

let users = [
	for i, x in usersList {
		x & {
			passbcrypt: _secrets.bcryptPasswords[x.name]
			// If uidnumber is not provided, set one starting with 3000
			if x.uidnumber == _|_ {
				uidnumber: i + 3000
			}
		}
	},
]

let userTemplate = """
	{{- range $u := . }}
		[[users]]
		  name = "{{$u.name}}"
		  uidnumber = {{$u.uidnumber}}
		  primarygroup = {{$u.primarygroup}}
		  {{- if $u.mail}}
		  mail = "{{$u.mail}}"  
		  {{- end }}
		  passbcrypt = "{{$u.passbcrypt}}"
	        {{- if $u.search}}
		    [[users.capabilities]]
		    action = "search"
		    object = "*"
	        {{end -}}
	{{ end }}
	"""

_userConfig: template.Execute(userTemplate, users)
