# proof-of-concept-reverse
This is a proof-of-concept stack containing five containers.

The first one of them can be considered a legacy web app that can no longer use current ssl, requiring termination further ahead. It is a basic nginx listening on port 80, serving a static html from an external folder. The second is a reverse proxy that handles the ssl termination for the first container. It has a self signed certificate. The legacy app only works on an internal network, to isolate it from the rest of the containers on the default network.

Both of this containers also server metrics that can be scraped with prometheus. This is in the third container, having them as a scrape target. Once series data is aquired, a grafana instance in a forth container could use this series to monitor the nginx performance.  The process of linking them could be automated, but its out of scope and the manual process is simple and well documented on the net.
On an Arm CPU,  apparently the Prometheus exporter has some issues (https://github.com/nginxinc/nginx-prometheus-exporter/issues/740). I can probably further test on x64 at some point, but the error is a scraping error internal to the prometheus app and not a config error. 
Other choices are checkmk and zabbix. Both require a heavier database (mysql, pg) and the requirement was to have an efficient stack

Since there was a need to monitor basic stats (RAM, CPU, storage, etc.), the fifth container is a cadvisor with this role. 

This being a docker stack, the actual need of ssh-ing into a container is akin to hunting flies with an elephant gun. We are not talking about full vm's, but light containers, where you docker exec -it bash into, once you reached the underlying vm via ssh jumps, vpn, proxy etc. But as a proof of concept, the cadvisor container was extended to provide sshd. 

The ssh is installed and started via a script, and using a hardened config. Furthermore, a basic fail2ban config was also included. The script was made executable, the authorized_keys was given propper permissions prior. 
But the config should be applied to the *underlying docker host* and not to the container in most cases. Even if a real life scenario requires ssh, this should be done in a propper bastion, built from the bare image, with the minimum amount of tools to not give an attacker even living off the land the ability to jump.

A few observations that come to mind:


-efficiency comes with compromises. zabbix would have handled monitoring without manual action or further automation, as long as the agent is pointed to the server it will selfregister and zabbix comes with most templates by default

-the monitoring is on the default network, with the assumption its used for multiple containers. It can be linked on internal only, and presented via the reverse

-a dedicated ssh bastion can be build, so as to not touch the cadvisor container, or even use the reverse container as a bastion jump host for the others

-separate files allow for vaulting of secrets, if adding users, databases etc

-since the reverse needs ssl, a certbot container or jwilder sidecar can be used with greater "fire-and-forget" potential
