variable "create_project_in_org" {
  description = "Controls if project should be created"
  type        = bool
  default     = false
}

variable "create_Project_folder" {
  description = "Controls if project folder should be created"
  type        = bool
  default     = false
}

variable "create_project_in_folder" {
  description = "Controls if project should be created in folder"
  type        = bool
  default     = false
}

variable "folder_name" {
  description 	= "GCP Project folder Name"
  type        	= string
  default		= ""
}

variable "parent_folder_name" {
  description 	= "GCP parent folder name"
  type        	= string
  default		= ""
}

variable "project_name" {
  description 	= "GCP Project Name"
  type        	= string
}

variable "project_id" {
  description 	= "GCP Project Id"
  type        	= string
}

variable "project_services" {
  description 	= "GCP services to be enabled in project"
  type        	= string
  default		= "iam.googleapis.com"
}

variable "organization_id" {
  description 	= "GCP Organization Id"
  type        	= string
  default		= ""
}

variable "Folder_id" {
  description 	= "GCP Organization Id"
  type        	= string
  default		= ""
}

variable "name" {
  description 	= "GKE Cluster Name"
  type        	= string
  default 		= "demo-cluster"
}

variable "clusterDescription" {
  description 	= "GKE Cluster Description"
  type        	= string
  default 		= ""
}

variable "region" {
  description 	= "GCP Region to create GKE Cluster"
  type        	= string
  default = "us-central1"
}

variable "zoneList" {
  description = "A list of zones names or ids in the region"
  type        = list(string)
  default 	= []
}

variable "Remove_GKE_Default_NodePool" {
  description 	= "GCP Region to create GKE Cluster"
  type        	= bool
  default = true
}

variable "initial_node_count" {
  description 	= "Number of worker node"
  type        	= number
  default = 1
}

variable "IsVM_Preemptible"{
	description 	= "Is GKE worker nodes are preemptible"
	type        	= bool
	default			= true
}

variable "machine_type" {
  description 	= "VM type for worker node"
  type        	= string
  default = "n1-standard-1"
}
