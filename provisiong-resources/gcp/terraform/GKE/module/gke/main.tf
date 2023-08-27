
locals {
  projectId = var.project_id
  projectName = var.project_name
}

resource "google_folder" "project_folder" {
  count = var.create_Project_folder ? 1 : 0
  display_name = var.folder_name
  parent       = var.parent_folder_name
}


resource "google_project" "my_project_org" {
  count = var.create_project_in_org ? 1 : 0
  name       = var.project_name
  project_id = var.project_id
  org_id     = var.organization_id
}


resource "google_project" "my_project_in_folder" {
  count = var.create_project_in_folder ? 1 : 0
  name       = var.project_name
  project_id = var.project_id
  folder_id     = var.folder_name
}



resource "google_project_service" "project_services" {
  count = var.create_project_in_org? 1: var.create_project_in_folder ? 1 : 0
  project = local.projectId
  service = var.project_services
  disable_dependent_services = false
}




resource "google_container_cluster" "default" {
  name        = var.name
  project     = local.projectId
  description = var.clusterDescription
  location    = var.region
  node_locations = var.zoneList

  remove_default_node_pool = var.Remove_GKE_Default_NodePool
  initial_node_count       = var.initial_node_count

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "default" {
  name       = "${var.name}-node-pool"
  project    = local.projectId
  location   = var.region
  cluster    = google_container_cluster.default.name
  node_count = var.initial_node_count

  node_config {
    preemptible  = var.IsVM_Preemptible
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

