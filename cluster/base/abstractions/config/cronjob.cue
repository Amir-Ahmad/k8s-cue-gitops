package config

#CronjobConfig: X={
	name:          string
	namespace:     string
	metadata:      #Metadata
	schedule:      string
	restartPolicy: "OnFailure" | *"Never"

	#PodConfig & {
		containerName: string | *X.name
	}
}
