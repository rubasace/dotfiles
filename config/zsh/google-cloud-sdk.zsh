gcloud_sdk="${HOMEBREW_PREFIX}/share/google-cloud-sdk"
[[ -f "${gcloud_sdk}/path.zsh.inc" ]] && source "${gcloud_sdk}/path.zsh.inc"
[[ -f "${gcloud_sdk}/completion.zsh.inc" ]] && source "${gcloud_sdk}/completion.zsh.inc"
unset gcloud_sdk
