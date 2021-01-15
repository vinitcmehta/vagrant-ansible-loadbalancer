Automation Logic Tech Test

Required Software Versions:
Windows 10
VirtualBox: 6.0.14    https://www.virtualbox.org/wiki/Downloads
VirtualBox Extension Pack 6.0.14    https://www.virtualbox.org/wiki/Downloads
Vagrant 2.2.6   https://www.vagrantup.com/downloads.html (Note: You will need to restart your computer after installing Vagrant)

How to run the solution:
After unzipping this archive, open the command prompt and switch to the directory of the unzipped archive.
Then run the command "vagrant up". This takes approximately 5-10 minutes. Example output is shown in the file "vagrant_output.txt" in this directory.
If you get any prompts asking you confirm if VirtualBox Interface can make a change, please click on "Yes" as this will allow Vagrant to set up the virtual network interfaces.
This will create the loadbalancer, 2 webservers and the Ansible controller node and then run the automated tests from the controller node, which will pass.

To prove that this solution is idempotent, please run "vagrant provision". This will run the Ansible playbook again and you can verify through the output that the solution remains stable.
The end of the output of this command is shown below:

PLAY RECAP *********************************************************************
controller                 : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
loadbalancer               : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
webserver1                 : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
webserver2                 : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

The only 2 tasks changed are the execution of the 2 automated tests which happen regardless as they are running shell scripts.

To validate the loadbalancer test, please run the following commands:
1. vagrant halt webserver2
2. vagrant ssh controller
3. cd /vagrant
4. ansible-playbook playbook.yml --tags "testrunner" -i hosts
5. exit

You will see the content test pass as webserver1 can still serve content but the loadbalance test will fail as there is only one webserver and the loadbalancer is in a degraded state. 

To validate the content test, please run the following commands:
1. vagrant halt webserver1
2. vagrant halt webserver2 (if not already done from above)
3. vagrant ssh controller
4. cd /vagrant
5. ansible-playbook playbook.yml --tags "testrunner" -i hosts
6. exit

You will now see the content test fail as there are no webservers left to serve content.

To get back to a fully working state, please run "vagrant destroy -f" and "vagrant up"
When you are done with this project, please run "vagrant destroy -f" to remove the VMs from your machine.
(Note: the "-f" flag here forces Vagrant to destroy the VMs without asking for a prompt to confirm for each VM)

Decisions made:
Ansible: Ansible is naturally idempotent and wanted to learn a new technology
Ansible local provisioning: To make it run easier from any host OS (especially seeing as Ansible doesn’t run off Windows) and reduces the dependencies required from the host OS
Ansible Controller node: This extra VM was created so that Ansible only has to be installed on this node and the playbook is only run off this node. This node is also used to run the tests and could be imagined as a bastion for this purpose.
Ansible copy module: I used this for the sudoers instead of Ansible's lineinfile module as this is the preferred technique to be used due to potential idempotentency issues with lineinfile.
Ansible tags were utilised so that anyone using this solution could easily just run the tests portion of the playbook instead of rerunning the entire playbook.
Ansible handlers were utilised in order to make this solution idempotent, one example would be that Nginx would only need to be restarted if Ansible detected that it changed the Nginx config.
Ansible register and whens were used in order to make sure tasks that are dependent on previous tasks being successful are not unnecessarily run.

Possible improvements:
The Ansible hosts file could be dynamically generated instead of a static hard-coded hosts file.
Ansible variables could have been utilised to make this project more maintainable and if any sensitive data was required as variables such as passwords, then Ansible Vault could be utilised.
Instead of just deploying an basic HTML WebApp, a more complex WebApp could have been deployed such as a Python Flask WebApp.
The tests could have been more production-grade, such as JUnit tests instead of simple shell scripts.
Currently, the loadbalancer itself is a single point of failure, to improve this, it would be possible to run 2 loadbalancer VMSs and run HAProxy instead of Nginx alongside with Keepalived on these to do VRRP to have an active-passive loadbalancer setup so if one fails, the other one will take over.

Compromises made:
Disabling gathering of facts: This was done to stop Ansible failing when demonstrating the tests validity and also there is a slight speed improvement doing this when running playbooks but best practise 
is to leave this enabled to collect useful information about the servers, especially in production systems.
Disabling host key checking in ansible.cfg - This is not best practice in a production environment as it would leave hosts suspectible to Man in the Middle attacks but this is needed for the Ansible local provisioner to allow SSH between the Ansible controller node and managed nodes.
An Ansible best practice that I did not follow here is "Top Level Playbooks Are Separated By Role". This was done as to run multiple Ansible playbooks in Vagrant, requires a lot of duplicated lines in the Vagrantfile which is unnecessary for an example this small but would make sense in a production environment.

Time spent:
3 hours learning Ansible and Vagrant
8 hours coding, deploying, debugging and documenting
