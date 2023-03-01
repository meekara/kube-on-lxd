# INTRODUCTION

#### Project Purpose 
Create a test environment on your pc/laptop for Kubernetes

#### Project requiremens

> :warning: A PC/Laptop with 60 GB Free Storage, at least 16 GB RAM and 8 core CPU LXD Installed and Default profile created with at least 32 GB storage at a lxc managed nic (eth0) having 192.168.1.0/24 subnet with birdged mode. All lxc instance will be create as vm to best simulate bare metal environment. 

<a href="https://linuxcontainers.org/lxd/docs/master/profiles/" target="_blank">LXC Profiles</a>

![image](https://user-images.githubusercontent.com/12957393/222286767-63c1a02f-0b89-42d7-927e-95632c8384e7.png)


**Step 00 :** Create VM's and Push Instance Environment Variables

**Step 01 :** Install All Packages to Nodes 

**Step 02 :** Install Bare Metal LoadBalancer - OpenELB 

# RESOURCES

#### Networking

 1. https://learnk8s.io/kubernetes-network-packets
   
 2. https://docs.google.com/spreadsheets/d/191WWNpjJ2za6-nbG4ZoUMXMpUK8KlCIosvQB0f-oq3k/edit#gid=907731238

#### Troubleshooting

 3. https://learnk8s.io/troubleshooting-deployments
