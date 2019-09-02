kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
$TOKEN=((kubectl -n kube-system describe secret default | Select-String "token:") -split " +")[1]
$CONTEXT=kubectl config current-context
kubectl config set-credentials ${CONTEXT} --token="${TOKEN}"
