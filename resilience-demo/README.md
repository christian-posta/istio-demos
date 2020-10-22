## Demo prep

1. Install Istio

```
istioctl install -y
```

1. Install Addons

```
kubectl apply -f $ISTIO_DIR/samples/addons
```

1. Set up the demo environment

```
./setup.sh
```

1. Run each of the demos (ideally in succession -- they build on each other)

* `./00-demo-canary.sh`
* `./10-demo-canary.sh`
* `./20-demo-canary.sh`
* `./30-demo-canary.sh`


1. At any point in the demo, can show grafana dashboard


```
istioctl dashboard grafana
```

