NUMBER_OF_WEBSERVERS = 2

Vagrant.configure("2") do |config|

  #Set the correct permissions on the folder in the host OS	
  config.vm.synced_folder "./", "/vagrant", 
     owner: "vagrant",
     mount_options: ["dmode=775,fmode=600"]

  #Create the loadbalancer 
  config.vm.define "loadbalancer" do |loadbalancer|
  	loadbalancer.vm.hostname = "loadbalancer"
    loadbalancer.vm.box = "ubuntu/bionic64"
    loadbalancer.vm.network "private_network", ip: "172.17.177.21"

  end

  #Create the defined number of webservers
  (1..NUMBER_OF_WEBSERVERS).each do |webserver_id|
    config.vm.define "webserver#{webserver_id}" do |webserver|
      webserver.vm.hostname = "webserver#{webserver_id}"
      webserver.vm.network "private_network", ip: "172.17.177.#{30+webserver_id}"
      webserver.vm.box = "ubuntu/bionic64"
    end
  end

  #Create the Ansible Controller and run the playbook from this server
  config.vm.define 'controller' do |controller|
  	controller.vm.hostname = "controller"
    controller.vm.network "private_network", ip: "172.17.177.11"
    controller.vm.box = "ubuntu/bionic64"
    controller.vm.provision :ansible_local do |ansible|
      ansible.playbook       = "playbook.yml"
      ansible.verbose        = true
      ansible.install        = true
      ansible.limit          = "all"
      ansible.inventory_path = "hosts"
    end
  end
end