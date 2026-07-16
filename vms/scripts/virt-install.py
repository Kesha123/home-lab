#!/usr/bin/env python3
import sys, yaml, shlex

with open(sys.argv[1]) as f:
    vm = yaml.safe_load(f)

cmd = ["virt-install", "--connect", vm["qemu-uri"], "--name", vm["name"],
       "--vcpus", str(vm["vcpu"]), "--memory", str(vm["memory"])]

for disk in vm.get("disks", []):
    cmd += ["--disk", ",".join(f"{k}={v}" for k, v in disk.items())]

if "networks" in vm:
    for net in vm["networks"]:
        cmd += ["--network", net]
elif "network" in vm:
    cmd += ["--network", vm["network"]]

for key in ("graphics", "console"):
    if key in vm:
        cmd += [f"--{key}", vm[key]]
cmd += vm.get("cmd-args", [])
print(shlex.join(cmd))
