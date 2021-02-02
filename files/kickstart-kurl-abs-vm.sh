#! /bin/bash

# Some additional manual setup steps for
# centos-8.3-kurl-beta-x86_64 vm from:
# https://confluence.puppetlabs.com/display/SUP/Replicated+Cheatsheet#ReplicatedCheatsheet-Gettingtestsystems
# These will likely go away as the vm is improved.

password=${1}

systemctl start containerd
while ! kubectl get nodes; do sleep 5; done
kubectl uncordon localhost.localdomain
kubectl wait --for=condition=Ready pod -l app=kotsadm --timeout=300s
if [ -n "${password}" ]; then
  printf "%s\n" "${password}" | kubectl kots reset-password default
else
  kubectl kots reset-password default
fi
