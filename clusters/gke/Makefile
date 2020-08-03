# Cluster variables
NAME 					?= demo
ZONE 					?= australia-southeast1
MACHINE_TYPE 	?= n1-standard-1
NODE_NUMBER 	?= 2

# Create a gke cluster
.PHONY: gke.create
gke.create: ## Create a gke cluster
	printf "🌀 Enabling required google services \n"
	gcloud services enable container.googleapis.com
	gcloud services enable containerregistry.googleapis.com
	gcloud auth configure-docker -q
	printf "🌀 Creating the GKE cluster - ${NAME} \n"
	gcloud beta container clusters create ${NAME} \
		--enable-autoupgrade \
		--enable-autoscaling --min-nodes=2 --max-nodes=5 --num-nodes=$(NODE_NUMBER) \
		--addons=Istio --istio-config=auth=MTLS_STRICT \
		--machine-type=${MACHINE_TYPE} \
		--zone=$(ZONE) \
		--no-enable-ip-alias
	printf "🌀 Getting the credentials for the cluster - ${NAME} \n"
	gcloud container clusters get-credentials ${NAME}
	printf "🌀 Enabling istio sidecar injection on namespace - default \n"
	kubectl label namespace default istio-injection=enabled
	printf "🌀 Granting cluster admin permission \n"
	kubectl create clusterrolebinding cluster-admin-binding \
		--clusterrole=cluster-admin \
		--user="$(gcloud config get-value core/account)"

# Delete a gke cluster
.PHONY: gke.delete
gke.delete: ## Delete a gke cluster
	printf "🌀 Deleting the GKE cluster - ${NAME}"
	gcloud container clusters delete ${NAME}
