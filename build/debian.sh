docker build -t opentask-debian -f build/Dockerfile.debian .
docker run --rm --entrypoint /bin/sh opentask-debian -c "cat bin/opentask" > opentask.debian
