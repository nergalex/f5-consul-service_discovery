#!/bin/bash

#VAR
EXTRA_CONSUL_DATACENTER="TotalInbound"
EXTRA_CONSUL_MASTER="10.100.0.60"
EXTRA_CONSUL_ENCRYPT="7H1UquAZVy8aVm1r4SeYQZRsh0xhklFjOaq8GpUbeFQ="

#Get IP
LOCAL_IPV4=$(ifconfig eth0 | grep -E -o "([0-9]{1,3}[\\.]){3}[0-9]{1,3}"  | head -n 1)

#Utils
sudo yum install -y unzip

#Download Consul
CONSUL_VERSION="1.8.4"
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

#Create Consul User
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

#Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl

cat << EOF > /etc/consul.d/consul.hcl
datacenter = "${EXTRA_CONSUL_DATACENTER}"
data_dir = "/opt/consul"
encrypt = "7H1UquAZVy8aVm1r4SeYQZRsh0xhklFjOaq8GpUbeFQ="
bind_addr = "${LOCAL_IPV4}"
client_addr = "${LOCAL_IPV4}"
EOF

cat << EOF > /etc/consul.d/client.hcl
advertise_addr = "${LOCAL_IPV4}"
retry_join = ["${EXTRA_CONSUL_MASTER}"]
EOF

#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status




