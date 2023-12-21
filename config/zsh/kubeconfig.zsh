folder_path="${HOME}/.kube"  # Replace this with your folder's path

for file in "$folder_path"/*; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "kubectx" ]; then
        file_paths+="$(realpath "$file"):"  # Append absolute path
    fi
done

export KUBECONFIG=${file_paths%:}