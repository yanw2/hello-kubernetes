# Cluster variables
NAME 					?= demo
VERSION 			?= 1.16.8-gke.15
ZONE 					?= australia-southeast1
MACHINE_TYPE 	?= n1-standard-2
NODE_NUMBER 	?= 5

# Create a gke cluster
.PHONY: gke.create
gke.create: ## Create a gke cluster
	printf "🌀 Enabling required google services"
	gcloud services enable container.googleapis.com
	gcloud services enable containerregistry.googleapis.com
	gcloud auth configure-docker -q
	printf "🌀 Creating the GKE cluster - ${NAME}"
	gcloud beta container clusters create ${NAME} \
		--enable-autoupgrade \
		--enable-autoscaling --min-nodes=3 --max-nodes=10 --num-nodes=$(NODE_NUMBER) \
		--addons=Istio --istio-config=auth=MTLS_STRICT \
		--cluster-version=${VERSION} \
		--machine-type=${MACHINE_TYPE} \
		--zone=$(ZONE) \
		--no-enable-ip-alias
	printf "🌀 Getting the credentials for the cluster - ${NAME}"
	gcloud container clusters get-credentials ${NAME}
	printf "🌀 Enabling istio sidecar injection on namespace - default"
	kubectl label namespace default istio-injection=enabled
	printf "🌀 Granting cluster admin permission"
	kubectl create clusterrolebinding cluster-admin-binding \
		--clusterrole=cluster-admin \
		--user="$(gcloud config get-value core/account)"

# Delete a gke cluster
.PHONY: gke.delete
gke.delete: ## Delete a gke cluster
	printf "🌀 Deleting the GKE cluster - ${NAME}"
	gcloud container clusters delete ${NAME}
