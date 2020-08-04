# Cluster variables
CLUSTER_NAME 			?= wenjing-sandbox
COMPUTE_ZONE 			?= australia-southeast1-a
RELEASE_CHANNEL  	?= regular
MACHINE_TYPE 			?= n1-standard-4
MIN_NODE_NUMBER		?= 1
MAX_NODE_NUMBER		?= 6

# Create a gke cluster
.PHONY: gke.create
gke.create: ## Create a gke cluster
	printf "🌀 Creating the GKE cluster - $(CLUSTER_NAME) \n"
	gcloud container clusters create $(CLUSTER_NAME) \
		--zone $(COMPUTE_ZONE) \
		--release-channel=$(RELEASE_CHANNEL) \
		--enable-autoscaling --min-nodes=$(MIN_NODE_NUMBER) --max-nodes=$(MAX_NODE_NUMBER)
	printf "\n🌀 Getting the credentials for the cluster - $(CLUSTER_NAME) \n"
	gcloud container clusters get-credentials $(CLUSTER_NAME) --zone $(COMPUTE_ZONE)
	printf "\n🌀 Granting cluster admin permission \n"
	kubectl create clusterrolebinding cluster-admin-binding \
		--clusterrole=cluster-admin \
		--user="$(gcloud config get-value core/account)"

# Delete a gke cluster
.PHONY: gke.delete
gke.delete: ## Delete a gke cluster
	printf "🌀 Deleting the GKE cluster - $(CLUSTER_NAME)"
	gcloud container clusters delete $(CLUSTER_NAME)
