# Install Minikube (architecture-specific)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
minikube start

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add stable https://charts.helm.sh/stable

# Install Prometheus
helm search hub prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm delete prometheus || :
helm install prometheus prometheus-community/prometheus -f scripts/helm_config.yaml

# Expose Prometheus as a service
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-external
minikube service prometheus-server-external
