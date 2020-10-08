#!/bin/bash
#Get IP
LOCAL_IPV4=$(ifconfig eth0 | grep -E -o "([0-9]{1,3}[\\.]){3}[0-9]{1,3}"  | head -n 1)
HOSTNAME=$(cat /etc/hostname)

cat << EOF > /etc/consul.d/arcadia_monitor_backend.json
{
  "service": {
    "name": "arcadia-monitor-backend",
    "port": 84,
    "checks": [
      {
        "id": "backend",
        "name": "nginx TCP Check",
        "tcp": "${LOCAL_IPV4}:84",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

# restart service
consul agent -dev -enable-script-checks -config-dir=/etc/consul.d -node=${HOSTNAME}


