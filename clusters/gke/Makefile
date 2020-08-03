# Cluster variables
NAME 					?= wenjing-sandbox 
ZONE 					?= australia-southeast1-c
MACHINE_TYPE 	?= n1-standard-1

# Create a gke cluster
.PHONY: gke.create
gke.create: ## Create a gke cluster
	printf "🌀 Creating the GKE cluster - $(NAME) \n"
	gcloud container clusters create $(NAME) --zone $(ZONE) --machine-type=$(MACHINE_TYPE)
	printf "🌀 Getting the credentials for the cluster - $(NAME) \n"
	gcloud container clusters get-credentials $(NAME) --zone $(ZONE)
	printf "🌀 Granting cluster admin permission \n"
	kubectl create clusterrolebinding cluster-admin-binding \
		--clusterrole=cluster-admin \
		--user="$(gcloud config get-value core/account)"

# Delete a gke cluster
.PHONY: gke.delete
gke.delete: ## Delete a gke cluster
	printf "🌀 Deleting the GKE cluster - $(NAME)"
	gcloud container clusters delete $(NAME)
