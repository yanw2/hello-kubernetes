# Cluster variables
CLUSTER_NAME 					?= poc
CLUSTER_VERSION 			?= 1.16.8-gke.15
CLUSTER_MACHINE_TYPE 	?= n1-standard-2
CLUSTER_NODE_NUMBER 	?= 4

# Create a gke cluster
.PHONY: gke.create 
gke.create: ## Create a gke cluster
	printf "🌀 Creating the GKE cluster - ${CLUSTER_NAME}"
	gcloud beta container clusters create ${CLUSTER_NAME} \
		--addons=Istio --istio-config=auth=MTLS_STRICT \
		--cluster-version=${CLUSTER_VERSION} \
		--machine-type=${CLUSTER_MACHINE_TYPE} \
		--num-nodes=${CLUSTER_NODE_NUMBER} \
		--no-enable-ip-alias
	printf "🌀 Getting the credentials for the cluster - ${CLUSTER_NAME}"
	gcloud container clusters get-credentials ${CLUSTER_NAME}
	printf "🌀 Enabling istio sidecar injection on namespace - default"
	kubectl label namespace default istio-injection=enabled
	printf "🌀 Granting cluster admin permission"
	kubectl create clusterrolebinding cluster-admin-binding \
		--clusterrole=cluster-admin \
		--user="$(gcloud config get-value core/account)"

# Delete a gke cluster
.PHONY: gke.delete
gke.delete: ## Delete a gke cluster
	printf "🌀 Deleting the GKE cluster - ${CLUSTER_NAME}"
	gcloud container clusters delete ${CLUSTER_NAME}
