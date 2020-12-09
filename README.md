# Kubernetes PVC Audit Tool

This tool is meant to test the validity of running Kubernetes storage provider in production.  It is based on libnfs and other user space block utilities.

## Usage

This utility is designed to run in Kubernetes.  You must already have a storage provisioner installed and configured.  You should also 

### Testing with NetApp
You must have NetApp Trident already configured and enabled.  

To run this utility, you simply edit the provided `nfstest.yaml` Kubernetes POD spec.  Change the NFS server IP address to point to your NetApp.

Substitute the PVC in the yaml with an existing Trident NAS PVC.

Then run `kubectl apply -f pvctest.yaml`

This will cause the utility to run a range of tests against the provided PVC.

Wait for the POD to run to completion.  You should see something as follows:

```
[root@ryan-controller-0 centos]# kubectl get pods                  
NAME                          READY   STATUS      RESTARTS   AGE   
postgres03-866d7c554d-t9f74   1/1     Running     0          6d7h  
pvctest                       0/1     Completed   0          7s    
```

### Analyzing the results

Data Vulnerability Test: See if the POD can access other PVCs:
```
# kubectl logs pvctest
```


Inspect the output.

If you can see the PVC's contents, then this demonstrates that this POD can succesfully access a PVC from some other deployment, without even having been granted that PVC via Kubernetes.  This would demonstrate a serious security flaw.


## Building

To build from source:

```
    ./bootstrap
    ./configure --with-examples
    make
```

To build a container, modify the provided `build_container.sh` to point to your repository.

```
	./build_container.sh
```

## License

This utility is BSD-licensed.
