# Kubernetes PVC Audit Tool

This tool is meant to test the validity of running a Kubernetes storage provider in production.  It is based on libnfs and other user space block utilities.

## Usage

This utility is designed to run in Kubernetes.  You must already have a storage provisioner installed and configured.  You should also 

### Testing with NetApp
You must have NetApp Trident already configured and enabled.  

To run this utility, you simply edit the provided `nfstest.yaml` Kubernetes POD spec.  Change the NFS server IP address to point to your NetApp.

For example, given the following PVC:

```
[root@ryan-controller-0 centos]# kubectl get pvc
NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgres-data-nfs-01   Bound    pvc-6ac7059b-0cb8-4db2-892d-4d2e0d11d3ba   10Gi       RWX            ontapnas       6d8h
```

Then the provided `pvctest.yaml` file looks as follows:

```
apiVersion: v1
kind: Pod
metadata:
  name: pvctest
  labels:
    app: pvctest
spec:
  containers:
  - name: pvctest-container
    image: gourao/pvctest
    imagePullPolicy: Always
      privid: true	
    command: ["/usr/local/bin/pvctest"]
    args: ["nfs://NETAPP_IP/trident_pvc_faba8030_57f4_4b62_9976_593633f17327"]
  restartPolicy: OnFailure

```

Substitute the PVC in the yaml with an existing Trident NAS PVC from your Kubernetes cluster.

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

An example output would look as follows:

```
    [root@ryan-controller-0 centos]# kubectl logs pvctest
	Starting PVC audit tests on nfs://172.31.50.245/trident_pvc_6ac7059b_0cb8_4db2_892d_4d2e0d11d3ba/pgdata


	-rw-------  1   999   999           36 postmaster.opts
	-rw-------  1   999   999          101 postmaster.pid
	-rw-------  1   999   999         1636 pg_ident.conf
	-rw-------  1   999   999         4535 pg_hba.conf
	-rw-------  1   999   999           88 postgresql.auto.conf
	-rw-------  1   999   999        22729 postgresql.conf
	-rw-------  1   999   999            3 PG_VERSION
	drwx------  4   999   999         4096 pg_logical
	drwx------  2   999   999         4096 pg_xact
	drwx------  2   999   999         4096 pg_stat_tmp
	drwx------  2   999   999         4096 pg_stat
	drwx------  2   999   999         4096 pg_tblspc
	drwx------  2   999   999         4096 pg_replslot
	drwx------  5   999   999         4096 base
	drwx------  4   999   999         4096 pg_multixact
	drwx------  2   999   999         4096 pg_twophase
	drwx------  2   999   999         4096 pg_subtrans
	drwx------  2   999   999         4096 pg_snapshots
	drwx------  2   999   999         4096 pg_serial
	drwx------  2   999   999         4096 pg_notify
	drwx------  2   999   999         4096 pg_dynshmem
	drwx------  2   999   999         4096 pg_commit_ts
	drwx------  2   999   999         8192 global
	drwx------  3   999   999         4096 pg_wal

	Done running tests on nfs://172.31.50.245/trident_pvc_6ac7059b_0cb8_4db2_892d_4d2e0d11d3ba/pgdata
	If you can see the PVC contents, this confirms a severe secuirty vulnerability with your Kubernetes storage provider.

```


## Building

To build from source:

```
    ./bootstrap
    ./configure --enable-examples
    make
```

To build a container, modify the provided `build_container.sh` to point to your repository.

```
	./build_container.sh
```

## License

This utility is BSD-licensed.
