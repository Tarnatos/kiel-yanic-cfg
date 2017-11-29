##mesh-announce clonen
#!/bin/bash
cd /opt
git clone https://github.com/ffnord/mesh-announce
cd mesh-announce

##iptables Regel anlegen

touch /etc/iptables.d/500-Allow-mesh-announce
cat <<-EOF>> /etc/iptables.d/500-Allow-mesh-announce
ip46tables -A bat-input -p udp -m udp --dport 1001 -m comment --comment respondd -j ACCEPT
ip46tables -A mesh-input -p udp -m udp --dport 1001 -m comment --comment respondd -j ACCEPT
EOF

build-firewall

##systemd Service anlegen
touch /etc/systemd/system/respondd.service
chmod 0644 /etc/systemd/system/respondd.service
cat <<-EOF>> /etc/systemd/system/respondd.service
[Unit]
Description=Respondd

[Service]
ExecStart=/opt/mesh-announce/respondd.py -d /opt/mesh-announce -i br-ffki -i ffki-mvpn -b bat-ffki
Restart=always
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable respondd
systemctl start respondd
systemctl status respondd
