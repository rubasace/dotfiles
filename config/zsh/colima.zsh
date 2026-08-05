# Docker against colima (company machines' container runtime). The docker
# context that colima sets on start covers the plain CLI, but tools that only
# honour DOCKER_HOST or the default socket path (Testcontainers, some build
# tooling) need it spelled out.
if command -v colima >/dev/null 2>&1; then
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
  # Ryuk must mount the daemon socket by its in-VM path, not the host path
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="/var/run/docker.sock"
fi
