Flow of demo..

* Install Istio 1.6.4
* Call `setup.sh`
* `demo-cacerts.sh`
* `demo-intermediate.sh`
* `demo-multiple-roots.sh`
* `demo-multiple-roots-intermediate.sh`


At any point you can call `verify-certs.sh` to check they were created as expected

At any point, you can call `reset-istio-ca.sh` to put the CA back into default settings

You can call `check-current-istio-certs.sh` to verify that the certs are in the correct state, depending on expectations. You can pass a dir in like we do in the demos. For example, you can call `check-current-istio-certs.sh ./certs/intermediate-rootA`