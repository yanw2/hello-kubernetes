# Cluster variables
NAME 					?= wenjing-sandbox
ZONE 					?= australia-southeast1-a
MACHINE_TYPE 	?= n1-standard-2
VERSION				?= 1.16.13-gke.1

# Create a gke cluster
.PHONY: gke.create
gke.create: ## Create a gke cluster
	printf "🌀 Creating the GKE cluster - $(NAME) \n"
	gcloud container clusters create $(NAME) \
		--release-channel=regular \
		--enable-ip-alias --cluster-ipv4-cidr=10.0.0.0/21 \
		--enable-autoscaling --min-nodes=1 --max-nodes=5 \
		--zone=$(ZONE)
	printf "\n🌀 Getting the credentials for the cluster - $(NAME) \n"
	gcloud container clusters get-credentials $(NAME) --zone $(ZONE)
	printf "\n🌀 Granting cluster admin permission \n"
	kubectl create clusterrolebinding cluster-admin-binding \
		--clusterrole=cluster-admin \
		--user="$(gcloud config get-value core/account)"

# Delete a gke cluster
.PHONY: gke.delete
gke.delete: ## Delete a gke cluster
	printf "🌀 Deleting the GKE cluster - $(NAME)"
	gcloud container clusters delete $(NAME)
