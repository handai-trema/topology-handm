sudo rm /tmp/*
./bin/trema killall --all
sudo ovs-vsctl del-br br0x1
sudo ovs-vsctl del-br br0x2
sudo ovs-vsctl del-br br0x3

