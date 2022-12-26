$go = <<-SCRIPT
/vagrant/provision/go.sh
/vagrant/provision/protoc.sh
SCRIPT

$client = <<-SCRIPT
/vagrant/provision/client.sh
SCRIPT

$proxy = <<-SCRIPT
/vagrant/provision/docker.sh
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "boxomatic/ubuntu-18.04"
  config.vm.box_version = "20210723.0.1"

  config.vm.define "server" do |node|
    node.vm.provision "shell", inline: $go, privileged: false
    node.vm.hostname = "server"
    node.vm.network "private_network", ip: "192.168.1.10", hostname: true, netmask: '255.255.255.0'
  end

  config.vm.define "client" do |node|
    node.vm.provision "shell", inline: $go, privileged: false
    node.vm.provision "shell", inline: $client, privileged: false
    node.vm.hostname = "client"
    node.vm.network "private_network", ip: "172.31.1.10", hostname: true, netmask: '255.255.255.0'
  end

  config.vm.define "proxy" do |node|
    node.vm.provision "docker"
    node.vm.provision "shell", inline: $proxy, privileged: false
    node.vm.hostname = "proxy"
    node.vm.network "private_network", ip: "172.31.1.20", hostname: true, netmask: '255.255.255.0'
  end

end
