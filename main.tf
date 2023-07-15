locals {

  # Create list of functions
  paths_list = [
    "getData",
    "putData",
    "postData",
    "deleteData"
  ]

  regions_list = [
    "northamerica-northeast1",
    "us-central1"
  ]

  list = distinct(flatten([ for region in local.regions_list : [
                    for path in local.paths_list : {
                        region = region
                        path = path
                    }
  ]]))

  
}

resource "google_compute_region_network_endpoint_group" "my_function_neg" {
  for_each              =   { for region in local.list : region.region => region...}
  name                  =   "neg-${each.key}"
  network_endpoint_type =   "SERVERLESS"
  region                =   each.key

  cloud_function {
    function = "my-function-${each.key}"
  }

  project = var.project_id

  depends_on = [
    google_cloudfunctions_function.my_function
  ] 
}

resource "google_compute_backend_service" "my_backends_serverless" {
    for_each        =   { for backend in local.list : backend.path => backend...} 
                     
    name = lower("backend-${each.key}")
    connection_draining_timeout_sec = 0
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    locality_lb_policy              = "ROUND_ROBIN"
    port_name                       = "http"
    project                         = var.project_id
    protocol                        = "HTTPS"
    session_affinity                = "NONE"
    timeout_sec                     = 30

    backend {
      # Fully-quallified-url-of-an-Instance-Group-Network-Endpoint  
      group =  google_compute_region_network_endpoint_group.my_function_neg["northamerica-northeast1"].self_link

    }

    backend {
        # Fully-quallified-url-of-an-Instance-Group-Network-Endpoint 
        group = google_compute_region_network_endpoint_group.my_function_neg["us-central1"].self_link
    }

    depends_on = [
     google_compute_region_network_endpoint_group.my_function_neg
  ] 
}

resource "google_compute_url_map" "my_url_map_serverless" {
  default_service = google_compute_backend_service.my_backends_serverless["getData"].self_link
  name            = "my-url-map-serverless"
  project         = var.project_id
  host_rule {
    hosts         = ["montreal_college"]
    path_matcher  = "path-matcher"
  }
   
  path_matcher {
    default_service = google_compute_backend_service.my_backends_serverless["getData"].self_link
    name            = "path-matcher"

        dynamic "path_rule" {
          for_each = google_compute_backend_service.my_backends_serverless
          content {
            paths   = [ format("/%s", lower(split("-", path_rule.value["name"])[1]))]
            service = path_rule.value["self_link"]
          }
        }
  }

  depends_on = [
     google_compute_backend_service.my_backends_serverless
  ]
  
}

resource "google_compute_target_https_proxy" "my_https_proxy_keep_alive" {
  name                        = "my-http-proxy-serverless"
  url_map                     = google_compute_url_map.my_url_map_serverless.self_link 
  project                     = var.project_id

  depends_on = [
     google_compute_url_map.my_url_map_serverless
  ]
}

resource "google_compute_global_forwarding_rule" "my_serverless_load_balancer" {
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "my-frontend"
  target                = google_compute_target_https_proxy.my_https_proxy_keep_alive.self_link
  port_range            = "443"
  project               = var.project_id

  depends_on = [
     google_compute_target_https_proxy.my_https_proxy_keep_alive
  ]

}


resource "google_cloudfunctions_function" "my_function" {
    for_each              =   { for region in local.list : region.region => region...}
    name                    =   "my-function-${each.key}"
    description             =   "My function"
    runtime                 =   "nodejs20"

    available_memory_mb     =   128
    source_archive_bucket   =   google_storage_bucket.my_bucket.name
    source_archive_object   =   google_storage_bucket_object.my_archive.name
    trigger_http            =   true
    entry_point             =   "helloHttp" 
    project                 =   var.project_id
    region                  =   each.key

    depends_on = [
      google_storage_bucket.my_bucket , google_storage_bucket_object.my_archive
   ] 
}

resource "google_storage_bucket" "my_bucket" {
  name     = "my-function-bucket-${var.project_id}"
  location = "US"
}

resource "google_storage_bucket_object" "my_archive" { 
  name      = "code.zip"
  bucket    = google_storage_bucket.my_bucket.name
  source    = "./code.zip"

  depends_on  = [
    google_storage_bucket.my_bucket
   ] 
}