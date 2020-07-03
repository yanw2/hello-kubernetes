#!/bin/bash - 
#===============================================================================
#          FILE: load-images.sh
#         USAGE: ./load-images.sh [kind|minikube] 
#   DESCRIPTION: This script is a workaround of pulling external images to
#                local kubernetes cluster running behind a proxy.
#       CREATED: 03/07/2020 17:57
#      REVISION: v0.1 
#===============================================================================

set -euo errexit

[ $# -ne 1 ] && echo 'USAGE: ./load-images.sh [kind|minikube]' && exit 1

images=(
  "bitnami/kube-state-metrics:1.9.7"
)

for image in "${images[@]}"; do
  image_log="$(echo "${image}" | sed 's/\///g')"
  # This is faster then checking via the internet if the image is present using just docker pull
  # run the downloads and load in parallel in the background to reduce time by ~30%
  ( if ! docker inspect --type=image "${image}" > /dev/null 2>&1  ; then
      docker pull "${image}" 2>&1
  fi
  if [ "$1" = 'kind' ]; then
    kind load docker-image --name kind --nodes kind-control-plane "${image}" 2>&1
  elif [ "$1" = 'minikube' ]; then 
    minikube cache add "${image}" 2>&1
  else
    echo '[ERROR] invalid argument!'
  fi
  echo "${image} load complete" ) 2>&1 &
done
wait
