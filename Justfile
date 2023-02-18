kubeconfig := "$HOME/.kube/c0"
kubectl := "kubectl --kubeconfig=" + kubeconfig
cluster_dir := justfile_directory() / "cluster"

export SOPS_AGE_KEY_FILE := justfile_directory() / "age"

set shell := ["bash", "-uc"]

# Print help
@help:
    just --list


# Decrypt secrets to disk
@decrypt-secrets:
    # Decrypt global secrets in config directory
    while IFS= read -r -d '' file; do \
        decryptedPath="${file%.cue}.unenc.cue"; \
        sops -d "${file}" > "${decryptedPath}"; \
        echo "Created ${decryptedPath}"; \
    done < <(find {{cluster_dir}}/config -name '*.sops.cue' -print0)

    # Decrypt all files under current working directory
    while IFS= read -r -d '' file; do \
        decryptedPath="${file%.cue}.unenc.cue"; \
        sops -d "${file}" > "${decryptedPath}"; \
        echo "Created ${decryptedPath}"; \
    done < <(find {{invocation_directory()}} -name '*.sops.cue' -not -path '{{cluster_dir}}/config/*' -print0)

# Remove decrypted secrets
@clean-secrets:
    find {{cluster_dir}} -name '*.sops.unenc.cue' -exec rm -v {} \;


# Deploy argo:
@deploy-argo:
    # Decrypt secrets
    just decrypt-secrets

    # Create argocd namespace
    kubectl create ns argocd --dry-run=client -o yaml | {{kubectl}} apply -f -

    # Deploy argocd
    cd {{cluster_dir}}/argocd/argocd/ && cue kdump . | {{kubectl}} apply -f -

    echo "Deploying argocd applications"
    cd {{cluster_dir}}/argocd/argocd-apps/ && cue dump . | {{kubectl}} apply -f -

    # remove temporarily decrypted secrets
    just clean-secrets


# ---------------------- misc ---------------- #

# Pass through kubectl commands, e.g. just k get pod
@k *command:
    {{kubectl}} {{command}}

# Edit a sops encrypted secret with vscode and print result
@edit-secret file:
    EDITOR="code --wait" sops "{{invocation_directory()}}/{{file}}"
    sops -d "{{invocation_directory()}}/{{file}}"
