Pre-requisites
* Set up Istio with the auto sidecar injector working
* If you install bookinfo into `default` ns, make sure you label it with injection:
`kubectl label namespace default istio-injection=enabled`


We should boot up about ~100 services:
/Users/ceposta/go/src/istio.io/tools/perf/load/setup_large_test.sh 5

^^ Note, on this, the `setup_large_test.sh` script will boot 20 services into a single namespace. Each service will have two replicas and will take up 50m of CPU. May be worth tuning that down to 25m in the `values.yaml` file of the chart. 

FYI: to delete the services:

``` bash
DELETE=true ./setup_large_test.sh 5
```

Once you have lots of service set up, you should also set up bookinfo:

```bash
k create -f latest/samples/bookinfo/platform/kube/bookinfo.yaml 
k create -f latest/samples/bookinfo/networking/bookinfo-gateway.yaml 
```

Should probably port-forward and checkout grafana:

```bash
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system | grep -i ^grafana | cut -d ' ' -f 1) 3000:3000 
```

To force the correct memory usage after updating with sidecar, you should log in to the pod you want to demonstrate and kill -9 the envoy proxy... alternatively could just restart all the pods


May want to import this for pod metrics: <-- this is what we use for the demo
https://grafana.com/dashboards/1471

May want this for node metrics:
https://grafana.com/dashboards/3131

For overall cluster:
https://grafana.com/dashboards/7249

Should also consider kubernetes app plugin:
https://grafana.com/plugins/grafana-kubernetes-app


Use this yaml for sidecar resource:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Sidecar
metadata:
  name: default
  namespace: default
spec:
  egress:
  - hosts:
    - "./*"
    - "istio-system/*"
```