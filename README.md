# k8s-cue-gitops

Kubernetes cluster powered by Gitops and cue. It's based off a similar private repository that I'm using to run a cluster for personal use. 

This is shared as an example of how [CUE](https://github.com/cue-lang/cue) can be used in a cluster with argocd, helm, kustomize, and sops.

This is a work in progress and has lots of room for improvement. 

Main tools used:
- [ArgoCD](https://github.com/argoproj/argo-cd) - GitOps for Kubernetes
- [Cuelang](https://github.com/cue-lang/cue) - Data templating language used for Kubernetes manifests
- [Sops](https://github.com/mozilla/sops) - encryption for secrets in repo
- [Just](https://github.com/casey/just) - Task runner


## Directory structure

```
cluster
├── apps                  # Apps to be deployed to the cluster
├── argocd                # 
│   ├── argocd            # Argocd and its related resources
│   ├── argocd-aoa        # All argocd apps and tools
│   ├── argocd-apps       # Top level argocd apps
├── base
│   ├── abstractions
│   │   ├── config        # config for abstractions, similar to a charts values.yaml in helm
│   │   └── objects       # merge of abstractions config to output kubernetes objects
│   └── kubernetes        # Define Kubernetes objects with ApiVersion and Kind
├── config                # Cluster and global variables/config
├── cue.mod               # generated kubernetes manifests for validation
├── go.mod                # used to generated cue.mod
├── go.sum                # used to generated cue.mod
├── main.cue              # Declare list of objects and abstractions, unify
├── main_tool.cue         # cue tool to output yaml (cue dump)
└── system                # Tooling needed for the cluster (e.g. ingress controller, cert manager)
```

## Generate some manifests on your computer

Pre-requisites:
1. Download [Sops](https://github.com/mozilla/sops), [Just](https://github.com/casey/just),  [Cue](https://github.com/cue-lang/cue), Helm, and kustomize.
2. Decrypt sops secrets
```
just decrypt-secrets
```

Generate manifests:
```
# all manifests
cd cluster
cue dump ./...

# All ingress objects
cue -t kind=Ingress ./...

# A particular app
cue dump ./app/jellyfin/

# Manifests for a system app that uses helm
cd cluster/system/external-dns
cue kdump .
```

Clean up secrets:
```
just clean-secrets
```

## Bootstrap Argocd

You can refer to the recipe `deploy-argo` in the Justfile. 

tldr:
1. Decrypt any sops.cue files in cluster/argocd/argocd/
2. Deploy manifests from cluster/argocd/argocd/
3. Deploy top level apps from cluster/argocd/argocd-apps/

Argocd will take over from there and deploy all the apps defined in cluster/argocd/argocd-aoa/.

## Useful links

[Argocd cue plugin definition](cluster/argocd/argocd/argocd-config-plugins.cue)

[App example](cluster/apps/jellyfin/app.cue)

[Text templating in cue to generate toml for glauth](cluster/system/glauth/user_def.cue) - This shows how flexible cue is.


## to do:

- Provide a working set up with [kind](https://github.com/kubernetes-sigs/kind)
- Automate version updates with [Renovate](https://github.com/renovatebot/renovate)
