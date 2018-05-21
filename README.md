## Kubernetes on AWS via Kismatic Enterprise Toolkit
The focus of this code is to deploy a basic Kubernetes cluster into AWS for testing and training purposes.
Upon successful completion, the following instances will have been provisioned:
  * 1 k8s master node, with etcd co-located
  * 2 k8s worker node
  * 1 k8s ingress controller node

All instances are configured with public IPs, however firewall rules will only allow SSH and kubeapi access from the CIDR block (`local_cidr`) defined in `terraform/terraform.tfvars`, or the default value as set in [variables.tf](terraform/variables.tf) if no `local_cidr` is provided.

Additionally, the following support infrastructure will be provisioned:
  * Custom VPC with a single subnet, with associated Internet gateway, and routing table
  * Newly generated SSH keypair (local and setup as AWS key pair)
  * Security groups for allowing SSH, kubeapi, and internal network traffic

### Prerequisites
* Amazon Web Service account (https://aws.amazon.com/free/)
* AWS CLI (https://aws.amazon.com/cli/)
* Terraform v0.11+ (https://www.terraform.io/downloads.html)

### Usage
Create a customized `terraform/terraform.tfvars` file ([tfvars file reference](https://www.terraform.io/intro/getting-started/variables.html#from-a-file)), key configurations are:

| Key              | Description       |
| ---------------- | ----------------- |
| `local_cidr`     | Local machine IP address (x.x.x.x/32) or CIDR range to allow access to the cluster |
| `aws_access_key` | AWS IAM user access key |
| `aws_secret_key` | AWS IAM user secret key |

Other settings can be configured such as instances sizes and region, as listed in `terraform/variables.tf`.

### Provision and Build a cluster
1. Deploy the AWS infrastructure:
  ```
  make prepare-instances
  make create-instances
  ```

1. Once the deployment completes, setup and execute Kismatic Enterprise Toolkit:
  ```
  make install-kismatic
  make prepare-kubernetes
  make install-kubernetes
  ```
  * _Note_: you may change the deployment name in the [Makefile](Makefile), or by passing `DEPLOY=myname` to the prepare and install commands.

1. When finished with the cluster, you may destroy all the resources that were provisioned. To do so, run the following:
  ```
  make destroy-instances
  make remove-kismatic
  ```
  * _Note_: If you changed the deployment name via command line, pass the name to the destroy command as well.
