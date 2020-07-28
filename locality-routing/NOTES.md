
Need to run this on a cluster with nodes in different AZs


istioctl proxy-config endpoints sleep-666475687f-6rr4h --cluster "outbound|80||fakeservice.default.svc.cluster.local" -o json

https://github.com/nicholasjackson/fake-service 