# Containers stack

* It runs on Fedora server with podman
* zot is configured as pull throuch cache registry
* caddy servese multiple roles:
    - for exposed services (in the future, such ass *arr stack) it should be doinf dns01 challenge on route53 domain
    - for internal services, used by other lab components, such as zot, it should be playing role of CA
* monitorig, authentik, dockhand
