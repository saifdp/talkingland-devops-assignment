# Deploying a Python Application on Kubernetes with Monitoring and Autoscaling

This guide outlines the steps to deploy a sample Python Flask application on a Kubernetes cluster, including setting up monitoring with Prometheus and Grafana, and enabling horizontal pod autoscaling (HPA).

## Prerequisites

*   **A running Kubernetes cluster:**  You need access to a Kubernetes cluster (Minikube, Kind, GKE, EKS, AKS, etc.).
*   **`kubectl` configured:** Your `kubectl` command-line tool must be configured to interact with your cluster.
*   **Docker installed and configured:** You'll need Docker to build and push the application image.
*   **A container registry:** You'll need a registry (Docker Hub, GCR, ECR, etc.) that your Kubernetes cluster can access to pull the application image.  You should be logged in to this registry.
*   **Helm (Strongly Recommended):**  Helm simplifies the installation of Prometheus and Grafana.
*   **Ingress Controller:** An Ingress controller (like Nginx Ingress Controller, Traefik, etc.) must be installed in your cluster. This guide assumes the Nginx Ingress Controller.


## Steps

### 1. Build and Push the Docker Image

1.  **Navigate to the `app` directory:**

    ```bash
    cd app
    ```

2.  **Build the Docker image:**  Replace `your-dockerhub-username` with your actual Docker Hub username (or your registry's username).

    ```bash
    docker build -t your-dockerhub-username/my-python-app:v1 .
    ```

3.  **Log in to your container registry:** (Example using Docker Hub)

    ```bash
    docker login
    ```

4.  **Push the image to the registry:**

    ```bash
    docker push your-dockerhub-username/my-python-app:v1
    ```

### 2. Deploy the Application to Kubernetes

1.  **Navigate to the `manifests` directory:**

    ```bash
    cd ../manifests
    ```

2.  **Edit `ingress.yaml`:**
    *   **Change `myapp.example.com`** to a hostname you control.  This hostname should point to your Ingress controller's external IP address.  For local testing, you can add an entry to your `/etc/hosts` file.  For production, configure your DNS provider.
    *   **Verify `ingressClassName`:** Ensure it matches your Ingress controller.  The example uses `nginx`.

3.  **Edit `deployment.yaml`:**
    *    **Change**  `your-dockerhub-username/my-python-app:v1` with your actual image name.

4.  **Apply the Kubernetes manifests:**

    ```bash
    kubectl apply -f .
    ```
    This command creates the Deployment, Service, Ingress, and HorizontalPodAutoscaler.

### 3. Install Metrics Server

The Metrics Server is required for HPA to function correctly.

```bash
kubectl apply -f [https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml](https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml)
```



### 4. Install Prometheus and Grafana (using Helm)
Important: These steps are conceptual.  You may need to customize them based on your cluster and desired configuration.  Using Helm charts is highly recommended for managing Prometheus and Grafana.

Create a namespace (optional but recommended):

```bash
kubectl create namespace monitoring
```
Add the Prometheus Helm repository:

```bash
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm repo update
```
Install Prometheus:

```bash
helm install prometheus prometheus-community/prometheus -n monitoring
```
Add the Grafana Helm repository:

```bash
helm repo add grafana [https://grafana.github.io/helm-charts](https://grafana.github.io/helm-charts)
helm repo update
```

Install Grafana:

```bash
helm install grafana grafana/grafana -n monitoring
```
5. Access and Configure Grafana
Get the Grafana admin password:

```bash
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
Port-forward to access the Grafana UI:

```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```

Open your browser to http://localhost:3000.  Log in with the username admin and the password you obtained in step 1.



Add Prometheus as a data source:

Go to Configuration -> Data Sources -> Add data source.
Select "Prometheus".
Set the URL to http://prometheus-server.monitoring.svc.cluster.local (adjust if your service name or namespace is different).
Click "Save & Test".
Create a Grafana dashboard:

Create a new dashboard.
Add panels and use PromQL queries to visualize metrics (see examples in the original response). Examples:
CPU Usage: rate(container_cpu_usage_seconds_total{pod=~"my-python-app.*"}[5m])
Memory Usage: container_memory_working_set_bytes{pod=~"my-python-app.*"}
6. Testing and Verification
Get the Ingress controller's external IP address:

```bash
kubectl get ingress my-python-app-ingress
```
Access your application: Open a browser and go to http://myapp.example.com (or the hostname you configured), using the Ingress IP address. You should see the application's output.

Test Autoscaling: Use a load testing tool (like hey, wrk, or Apache Bench) to generate traffic:

```bash
hey -n 10000 -c 100 [http://myapp.example.com/](http://myapp.example.com/)
```

Monitor CPU usage in Grafana.  The number of replicas should scale up and down based on the load.


Check Prometheus:  You can access the Prometheus UI (usually via port-forwarding) to verify that it's scraping metrics from your application.