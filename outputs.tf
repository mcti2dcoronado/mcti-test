output "neg_northeast1_name" {
    description     =   "Endpoint Name for the northamerica-northeast1 region."
    value           =   google_compute_region_network_endpoint_group.my_function_neg["northamerica-northeast1"].name
}

output "neg_central1_name" {
    description     =   "Endpoint Name for the us-central1 region"
    value           =   google_compute_region_network_endpoint_group.my_function_neg["us-central1"].name 
}

output "neg_northeast1_id" {
    description     =   "Identifier for the northamerica-northeast1 region"
    value           =   google_compute_region_network_endpoint_group.my_function_neg["northamerica-northeast1"].id
}

output "neg_central1_id" {
    description     =   "Identifier for the us-central1 region"
    value           =   google_compute_region_network_endpoint_group.my_function_neg["us-central1"].id
}

output "neg_northeast1_uri" {
    description     =   "Self link or URI for the northamerica-northeast1 region"
    value           =   google_compute_region_network_endpoint_group.my_function_neg["northamerica-northeast1"].self_link
}

output "neg_central1_uri" {
    description     =   "Self link or URI for the us-central1 region"
    value           =   google_compute_region_network_endpoint_group.my_function_neg["us-central1"].self_link
}