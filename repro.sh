#!/bin/bash
if ! kubectl get ns buildkit-repro
then
  kubectl create ns buildkit-repro
fi

kubectl apply -f manifests/ -n buildkit-repro


until kubectl get pods -n buildkit-repro buildkitd-0 |grep -E "1/1.*Running" \
  && kubectl get pods -n buildkit-repro registry-0 |grep -E "1/1.*Running"
do
  echo "Waiting for buildkit and registry"
  sleep 3
done

echo "### Buildkit du ###"
kubectl exec -n buildkit-repro buildkitd-0 -- buildctl du |grep Total
echo "### df -h ###"
kubectl exec -n buildkit-repro buildkitd-0 -- df |grep /var/lib/buildkit
echo "### /var/lib/buildkit/runc-overlayfs du ###"
kubectl exec -n buildkit-repro buildkitd-0 -- du -d1 /var/lib/buildkit/runc-overlayfs
echo "### ls /var/lib/buildkit/runc-overlayfs/snapshots/ ###"
kubectl exec -n buildkit-repro buildkitd-0 -- ls -lah /var/lib/buildkit/runc-overlayfs/snapshots

kubectl exec -n buildkit-repro buildkitd-0 -- mkdir -p /src/
kubectl cp ./testapp/ buildkit-repro/buildkitd-0:/src/
echo "######################"
echo "Running some builds..."
echo "######################"
for i in {1..50}
do
  kubectl exec -n buildkit-repro buildkitd-0 -- \
    buildctl build --frontend dockerfile.v0 \
      --local context=/src/testapp/ --local dockerfile=/src/testapp/ \
      --output type=image,name=registry-0.registry.buildkit-repro.svc:5000/repro/testapp,push=true,registry.insecure=true > /dev/null 2>&1
  kubectl exec -n buildkit-repro buildkitd-0 -- sh -c 'echo "$(date) busted!" >> /src/testapp/cache-buster'
done

echo "### Buildkit du ###"
kubectl exec -n buildkit-repro buildkitd-0 -- buildctl du |grep Total
echo "### df -h ###"
kubectl exec -n buildkit-repro buildkitd-0 -- df |grep /var/lib/buildkit
echo "### /var/lib/buildkit/runc-overlayfs du ###"
kubectl exec -n buildkit-repro buildkitd-0 -- du -d1 /var/lib/buildkit/runc-overlayfs
echo "### ls /var/lib/buildkit/runc-overlayfs/snapshots/ ###"
kubectl exec -n buildkit-repro buildkitd-0 -- ls -lah /var/lib/buildkit/runc-overlayfs/snapshots


echo "### Pruning ###"
kubectl exec -n buildkit-repro buildkitd-0 -- buildctl prune --all |grep Total

echo "### Buildkit du ###"
kubectl exec -n buildkit-repro buildkitd-0 -- buildctl du |grep Total
echo "### df -h ###"
kubectl exec -n buildkit-repro buildkitd-0 -- df |grep /var/lib/buildkit
echo "### /var/lib/buildkit/runc-overlayfs du ###"
kubectl exec -n buildkit-repro buildkitd-0 -- du -d1 /var/lib/buildkit/runc-overlayfs
echo "### ls /var/lib/buildkit/runc-overlayfs/snapshots/ ###"
kubectl exec -n buildkit-repro buildkitd-0 -- ls -lah /var/lib/buildkit/runc-overlayfs/snapshots
