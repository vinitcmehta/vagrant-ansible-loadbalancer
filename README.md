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


