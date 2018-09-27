# Ansible Playbooks

### wise.vote

Before first deployment, you should initialize a server, to make sure that everything what is needed for later deployment will be installed beforehand.
    
    ansible-playbooks wise.vote/init-server.yml

Later, to deploy a new version of https://wise.vote/ just run:

    ansible-playbooks wise.vote/wise.vote.yml

This deploy two services

* https://github.com/wise-team/steem-wise-manual.git
  * and mounts its on https://wise.vote/
* https://github.com/wise-team/steem-wise-voter-page.git
  * and mounts its https://wise.vote/voting-page/

