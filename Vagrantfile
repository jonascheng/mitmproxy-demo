$script = <<-SCRIPT
/vagrant/provision/docker.sh
/vagrant/provision/go.sh
/vagrant/provision/protoc.sh
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "boxomatic/ubuntu-18.04"
  config.vm.box_version = "20210723.0.1"
  config.vm.provision "docker"
  config.vm.provision "shell", inline: $script, privileged: false

  config.vm.define "client" do |node|
    node.vm.hostname = "server1"
    node.vm.network "private_network", ip: "10.1.0.10", hostname: true
  end

end
