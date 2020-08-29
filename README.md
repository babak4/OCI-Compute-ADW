# OCI-Compute-ADW
A repository of Terraform config files for setting up a network, a Python enabled VM and ADW on Oracle Cloud Infrastructure.

I created this repo just to help me start using the free resources on OCI, but I came across so many issues -mainly for setting up the DB connectivity- that I decided to make life easier for anybody else who wants to use the same free resources.

### Disclaimer!
This repo was developped as **a quick hacky solution** for a small side-project. That's all it is. There are many things wrong with it. See the `warnings` below.

## A Free Python-Ready VM and A DB
This repository can be used to create the following **FREE** resources on Oracle Cloud Infrastructure:

- A VCN
- A subnet with access to internet and egress (ssh, icmp) limited to the local node which is running the Terraform configuration
- Autonomous Data Warehouse (free - public endpoint - very easy to switch with an Autonomous Transaction Processing DB) with only the following IP addresses whitelisted:
    - The local node on which the Terraform configuration is running
    - The provisioned Ubuntu 20.10 VM (see below)
- An Ubuntu 20.10 VM (VM.Standard.E2.1.Micro) with
    - Oracle Client 19.8 installed and configured to connect to ADW
    - Python 3.8
    - **Configured oci cli (silent install)**
    - a virtual env, few sample Python libraries, and a simple script to test the ADW connectivity

### Note: 
You **can** swap the ubuntu with Oracle Linux or even better, an Autonomous Oracle Linux ("O.M.G!"), **BUT** don't complain when you have to wait almost 10 minutes for a simple `yum update` to finish! Also you'll get [almost] the **latest version of Python** with an Ubuntu 20.10.

## How to deploy

1. Provide values for all the required Terraform variables listed in `variables.tf` (except `local_ip_address`) either by supplying a `terraform.tfvars` file, environment variables, or run-time variables
2. Run the following command to set the required environment variable: 

```
export TF_VAR_local_ip_address=`curl 'https://api.ipify.org'`
```
3. Run `terraform plan` to make check the resources which will be created/destroyed/changed
4. Run `terraform apply` to deploy

## Warnings!
- **Use-case:** This configuration is meant to be used for setting up a personal dev environment or running very small projects.
- **Security:** Because private endpoints cannot be assigned to **free** Autonomous Oracle Databases and there are no explicit guarantees that the traffic between the ADW and the VM will not be directed over public internet, **this deployment cannot be regarded as a secure platform** and **YOU** are responsible for security of the resources that you've deployed using this repository!
- **Security:** This config is not CI-ready. The admin password of the database can be found in the terraftom state file (`terraform.tfstate`) in plain text!
- Also this configuration should **not** be regarded as an example of best practices in terms of how to use Terraform, Terraform for deploying resources in OCI, OCI, or IaaS services in general. 
- One major anti-pattern in this config is relying so heavily on Terraform's remote executor to run bash setup commands. Yes, a tool such as Ansible is the correct one to use for configuring the instance itself.

## Want to add/change something?
That's great! I really appreciate your contribution. Raise a PR, please!
