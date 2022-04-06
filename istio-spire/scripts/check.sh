CONTEXT=${1:-kind}
NAMESPACE=${2:-istio-system}

until [ $(kubectl --context $CONTEXT -n $NAMESPACE get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the $NAMESPACE pods to become ready"
  sleep 1
done

