# spark-on-k8s-dotnet
Kubernetes friendly Spark images with dotnet for working with GoogleCloudPlatform/spark-on-k8s-operator


## References
- [Spark](https://github.com/apache/spark)
- [dotnet/spark](https://github.com/dotnet/spark)
- [spark-on-k8s-operator](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator)
- [spark-on-k8s-operator helm chart](https://github.com/helm/charts/tree/master/incubator/sparkoperator)


## Quick Instructions for Mac
1. [Install Docker](https://docs.docker.com/docker-for-mac/install/)
2. [Enable Kubernetes in Docker](https://docs.docker.com/docker-for-mac/#kubernetes)
3. Initialize Tiller `./initialize-helm.sh`
4. Install Spark Operator `./apply-spark-on-k8s-operator.sh`
5. Create Spark Image `build-from-prebuilt.sh`
6. Run Spark Job `apply-spark-csharp-from-prebuilt.sh`


## Quick Instructions for Windows
NOTE: Run commands in `powershell` on Windows
1. [Install Docker](https://docs.docker.com/docker-for-windows/install/)
2. [Enable Kubernetes in Docker](https://docs.docker.com/docker-for-windows/#kubernetes)
3. Initialize Tiller `./initialize-helm.ps1`
4. Install Spark Operator `./apply-spark-on-k8s-operator.ps1`
5. Create Spark Image `build-from-prebuilt.ps1`
6. Run Spark Job `apply-spark-csharp-from-prebuilt.ps1`


## Verbose Instructions
NOTE: Run commands in `powershell` on Windows
- Install Docker
  - [General](https://docs.docker.com/install/)
  - [Mac](https://docs.docker.com/docker-for-mac/install/)
  - [Windows](https://docs.docker.com/docker-for-windows/install/)
- Enable Kubernetes in Docker
  - [Mac](https://docs.docker.com/docker-for-mac/#kubernetes)
  - [Windows](https://docs.docker.com/docker-for-windows/#kubernetes)
- Initialize Tiller
  - NOTE: There are shortcuts in the repo's root
  - Long Form: `helm init --upgrade --force-upgrade --wait --debug`
  - Mac Shortcut: `./initialize-helm.sh`
  - Windows Shortcut: `./initialize-helm.ps1`
- OPTIONAL: Install Kubernetes Dashboard
  - NOTE: The repo's shortcuts will setup the dashboard and add a token to your `~/.kube/config` for authentication [[REF]](http://collabnix.com/kubernetes-dashboard-on-docker-desktop-for-windows-2-0-0-3-in-2-minutes/)
  - NOTE: Use the Kubeconfig option when logging into the dashboard
  - Mac Shortcut: `./apply-k8s-dashboard.sh`
  - Windows Shortcut: `./apply-k8s-dashboard.ps1`
- Install spark-on-k8s-operator with webhook enabled
  - Long Form:
    ``` bash
    kubectl create namespace spark-jobs

    helm upgrade spark-operator sparkoperator \
    --namespace spark-operator \
    --install --force --debug \
    --set sparkJobNamespace=spark-jobs \
    --set enableWebhook=true \
    --set serviceAccounts.spark.name=spark \
    --set serviceAccounts.sparkoperator.name=spark-operator \
    --repo http://storage.googleapis.com/kubernetes-charts-incubator
    ```
  - Mac Shortcut: `./apply-spark-on-k8s-operator.sh`
  - Windows Shortcut: `./apply-spark-on-k8s-operator.ps1`
- Create Spark container image with dotnet/spark installed
  - NOTE: Choose one
  - OPTION 1 (**prebuilt**): Use prebuilt binaries from Spark and dotnet/spark
    - NOTE: Currently targeting `v2.4.3` of Spark, can be changed by editing the `spark-on-k8s-dotnet-from-prebuilt` service in `docker-compose.yaml`
    - Long Form: `docker-compose build spark-on-k8s-dotnet-from-prebuilt`
    - Mac Shortcut: `build-from-prebuilt.sh`
    - Windows Shortcut: `build-from-prebuilt.ps1`
  - OPTION 2 (**source**): Build from Spark and dotnet/spark source code
    - NOTE: Currently targeting `v2.4.4` of Spark, can be changed by editing the `spark-on-k8s-dotnet-from-source` service in `docker-compose.yaml`
    - **WARNING**: dotnet/spark does not currently support Spark `v2.4.4` so you must downgrade the version for this to work
    - Long Form: `docker-compose build spark-on-k8s-dotnet-from-source`
    - Mac Shortcut: `build-from-source.sh`
    - Windows Shortcut: `build-from-source.ps1`
- Run dotnet sample Spark job
  - NOTE: Varies depending on if you chose **prebuilt** or **source**
  - Prebuilt: Use this option if you chose prebuilt above
    - Long Form: `kubectl apply -f ./from-prebuilt/spark-csharp.yaml`
    - Mac Shortcut: `apply-spark-csharp-from-prebuilt.sh`
    - Windows Shortcut: `apply-spark-csharp-from-prebuilt.ps1`
  - Source: Use this option if you chose source above
    - Long Form: `kubectl apply -f ./from-source/spark-csharp.yaml`
    - Mac Shortcut: `apply-spark-csharp-from-source.sh`
    - Windows Shortcut: `apply-spark-csharp-from-source.ps1`


## Folder Layout
- `/` folder
  - Shortcut scripts
  - `docker-compose.yaml` for building Spark docker images with spark/dotnet installed
- `prometheus-conf` folder
  - Used by docker images for configuring prometheus
- `from-prebuilt` folder
  - `Dockerfile` for building Spark docker image from prebuilt binaries with spark/dotnet installed
  - `*.yaml` files used to create `SparkApplication` CRDs for spark-on-k8s-operator
- `from-source` folder
  - `Dockerfile` for building Spark docker image from source with spark/dotnet installed
  - `*.yaml` files used to create `SparkApplication` CRDs for spark-on-k8s-operator
