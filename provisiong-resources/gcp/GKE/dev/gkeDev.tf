provider "google" {
  region = "us-central1"
  
}


module "gke" {
  source                = "../module/gke"
  project_name			= "My First Project"
  project_id			= "utility-heading-301007"
  name                  = "gke-demo-cluster"
  zoneList    			= ["us-central1-a","us-central1-b","us-central1-c"]
  initial_node_count	= 1
  machine_type			= "n1-standard-1"
}
