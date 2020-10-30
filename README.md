# home-lab
This repository hosts the code and configuration for my home infrastructure. This runs things that I actually use, as well as acting as a proving ground for different infrastructure tools that I want to get to know. 

There are several major components to this network:
1. An AWS EC2 instance running HA proxy to proxy connections from the public internet to my local home network over a secure connection
2. The terraform to configure my home router (UDM Pro from Ubiquti) with all the necessary firewall rules and port forwarding
3. A bunch of Ansible code to setup a Kubernetes cluster on a bunch of local machines using Ansible and Kubeadm
4. The applications running on that cluster

These are all deployed using Github Actions. Many of the IPs and other secrets are obscured via the Secrets function for Github actions. Although this maybe be replaced with a Jenkins instance in the future. 
