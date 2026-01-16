# docker.host=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}') >> ~/.testcontainers.properties
podman machine start
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export TESTCONTAINERS_RYUK_DISABLED=true
