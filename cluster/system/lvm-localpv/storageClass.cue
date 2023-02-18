package kube

objects: storageClass: "lvm-ext4": {
	allowVolumeExpansion: true
	provisioner:          "local.csi.openebs.io"
	parameters: {
		storage:           "lvm"
		volgroup:          "vg0"
		fsType:            "ext4"
		shared:            "yes"
		volumeBindingMode: "WaitForFirstConsumer"
	}
}
