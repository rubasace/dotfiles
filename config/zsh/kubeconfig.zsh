# Merge every kubeconfig under ~/.kube into KUBECONFIG (kubectx state file excluded)
kube_dir="$HOME/.kube"
kubeconfig_paths=()
if [[ -d "$kube_dir" ]]; then
  for file in "$kube_dir"/*(N-.); do
    [[ "$(basename "$file")" == "kubectx" ]] && continue
    kubeconfig_paths+=("$file")
  done
fi
export KUBECONFIG="${(j.:.)kubeconfig_paths}"
unset kube_dir kubeconfig_paths file
