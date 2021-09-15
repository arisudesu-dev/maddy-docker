# maddy-docker ✉️+🐳

![Build status](https://img.shields.io/badge/build-works%20on%20my%20machine-brightgreen)

Docker image of [foxcpp/maddy](https://github.com/foxcpp/maddy) without cringe. Changes included:
- Dirs changes to familiar Linux ones, which include:
  - Configuration is `/etc/maddy/maddy.conf`
  - Certs are located in `/etc/maddy/certs/`
  - State is located in `/var/lib/maddy/`
- ENTRYPOINT removed and replaced with CMD to allow running `maddy` and `maddyctl` from the image without much friction:
  - `maddy` daemon:  
    `docker run ghcr.io/arisudesu-dev/maddy:$TAG`
  - `maddyctl`:  
    `docker run ghcr.io/arisudesu-dev/maddy:$TAG maddyctl ...`
