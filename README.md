# Serverless Regional External Application Load Balancer

## Project

Deploying a regional external application load balancer with Cloud Functions using Git repository, Google Cloud Platform, and Terraform.  

- **Terraform Organization:** dcoronado-mcit
- **Terraform Workspace:** mcti-test
- **GCP Project:** montreal-project-mcit
- **Git Name:** mcti-test

## How to set up a regional external Application Load Balancer with Cloud Functions

### Diagram
![screenshot](readme/diagram.jpg)

### Description
A regional external Application Load Balancer is a region's proxy-based Layer 7 load balancer.  
It runs and scales Serverless services behind a single external IP address. 
This external Application Load Balancer distributes **HTTP** traffic to a serverless network endpoint. 
The serverless network endpoint group (NEG) specifies a group of backend endpoints for the load balancer pointing to a Cloud Functions service.
The Cloud Function code is saved in a bucket service.

**Notes:** 
- HTTPS is not implemented
- The serverless NEG and the load balancer must be in the same region as the Cloud Functions service. 

### Features 
Load balancing is essential for applications that need high availability, reliability, and scalability. 
A Load Balancer could route traffic to the closest user location for serverless computing services such as cloud Functions, improving experience and latency for the end user. 

### IAM (Service Account)
**Name:** mcti-tutorial

**Roles:**
- Cloud Functions Admin
- Compute Instance Admin (v1)
- Compute Network Admin
- Security Admin
- Storage Admin


### Resources

| # | Resource  |  Description |
|---|---------- |  ------------------ | 
|`1`| google_compute_region_network_endpoint_group| Create a region network endpoint group |
|`2`| google_compute_backend_service| Define a group of virtual machines that will serve traffic for load balancing|
|`3`| google_compute_url_map | Route requests to a backend service based on rules defined for path|
|`4`| google_compute_target_http_proxy| Route incoming HTTP requests to a URL map|
|`5`| google_compute_global_forwarding_rule| Forward traffic to the load balancer for HTTP load balancing|
|`6`| google_cloudfunctions_function| Creates a Cloud Function resource|
|`7`| google_cloudfunctions_function_iam_member| IAM entry for all users to invoke the function |
|`8`| google_storage_bucket| Creates a new bucket in Google cloud storage service  |
|`9`| google_storage_bucket_object| Creates a new object inside an existing bucket|

### Cloud Functions

index.js
```
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  res.send(`Hello ${req.query.name || req.body.name || 'World'}!`);
});
```

package.json

```
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
```


## References

|Description| URL|
|-----|-----|
|google_compute_region_network_endpoint_group| ![google_compute_region_network_endpoint_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group)|
||[![Vishnu Sivadas](https://www.vishnusivadas.com/github/codequality.svg?style=flat)](https://github.com/VishnuSivadasVS)|
|||
|||
|||
|||
|||
|||
