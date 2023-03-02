[[ -z "${LXD_K8LAB_ENV}" ]] && echo "Not in LXC Node";exit || echo "Setup Master and Nodes"

hstName=$(hostname)

echo "#Step Update Repo"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

echo "#Step Setting IP"

setHostIp(){
case "$hstName" in

master)
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
HOSTNAME=master
IPADDR=192.168.1.10
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=192.168.1.1
NM_CONTROLLED=no
TYPE=Ethernet
EOF
hostnamectl set-hostname master
sed -i '1d' /etc/hosts
;;
w01)
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
HOSTNAME=w01
IPADDR=192.168.1.20
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=192.168.1.1
NM_CONTROLLED=no
TYPE=Ethernet
EOF
hostnamectl set-hostname w01
sed -i '1d' /etc/hosts
;;
w02)
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
HOSTNAME=w02
IPADDR=192.168.1.21
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=192.168.1.1
NM_CONTROLLED=no
TYPE=Ethernet
EOF
hostnamectl set-hostname w02
sed -i '1d' /etc/hosts
;;
esac
systemctl restart network
}

chkIP=$(grep 'IPADDR=192.168.1.' /etc/sysconfig/network-scripts/ifcfg-eth0)

if [ -z "$chkIP" ]
then 
	setHostIp
fi

echo "#Step Package Installation"
yum -y install epel-release
yum -y install htop
yum -y install git e2fsprogs

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable containerd
systemctl start containerd

yum install -y kubelet kubeadm kubectl
systemctl enable kubelet
systemctl start kubelet

#Resize Nodes HDD to 10G ** https://discuss.linuxcontainers.org/t/how-can-i-expand-the-size-of-vm/7618/4
growpart /dev/sda 2
resize2fs /dev/sda2

echo "#Step Setting Hostnames"
setHostName()
{
cat <<EOF >> /etc/hosts
192.168.1.10 master.kubelab master
192.168.1.20 w01.kubelab w01
192.168.1.21 w02.kubelab w02
EOF
}

chkIP=$(grep 'master.kubelab' /etc/hosts)

if [ -z "$chkIP" ]
then
        setHostName
fi

echo "#Step 2 Firewall - Master"

if [ "$hstName" = "master" ]
then
#Install helm for Control Plane
yum -y install openssl
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
else
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
fi

echo "#Step Setup Systemctl"
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

#Step 
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sed -i '/swap/d' /etc/fstab
swapoff -a

#Final Step 
echo "Final Step Bridge and Containerd"
modprobe br_netfilter
FILE=/etc/containerd/config.toml
if [ -f "$FILE" ]; then
   rm $FILE 
fi
systemctl restart containerd
