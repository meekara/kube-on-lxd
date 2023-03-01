#Create Instance
lxc launch images:centos/7 master --vm -c limits.cpu=2 -c limits.memory=2GiB
lxc launch images:centos/7 w01 --vm -c limits.cpu=2 -c limits.memory=2GiB
lxc launch images:centos/7 w02 --vm -c limits.cpu=2 -c limits.memory=2GiB

#Push Env File
sleep 30
lxc file push lxd-k8s-lab.sh master/etc/profile.d/
lxc exec master -- bash -c 'chown root:root /etc/profile.d/lxd-k8s-lab.sh'
lxc file push lxd-k8s-lab.sh w01/etc/profile.d/
lxc exec w01 -- bash -c 'chown root:root /etc/profile.d/lxd-k8s-lab.sh'
lxc file push lxd-k8s-lab.sh w02/etc/profile.d/
lxc exec w02 -- bash -c 'chown root:root /etc/profile.d/lxd-k8s-lab.sh'
