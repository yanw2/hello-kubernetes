# Cluster variables
CLUSTER_NAME 			?= wenjing-sandbox
COMPUTE_ZONE 			?= australia-southeast1-a
MACHINE_TYPE 			?= n1-standard-3
RELEASE_CHANNEL  	?= regular

# Create a gke cluster
.PHONY: gke.create
gke.create: ## Create a gke cluster
	printf "🌀 Creating the GKE cluster - $(CLUSTER_NAME) \n"
	gcloud container clusters create $(CLUSTER_NAME) \
		--release-channel=$(RELEASE_CHANNEL) \
		--enable-ip-alias --cluster-ipv4-cidr=10.0.0.0/21 \
		--enable-autoscaling --min-nodes=1 --max-nodes=5 \
		--zone=$(COMPUTE_ZONE)
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
