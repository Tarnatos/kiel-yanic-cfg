# GO API download
cd /usr/local/
wget https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz
tar xvf go1.8.linux-amd64.tar.gz
rm go1.8.linux-amd64.tar.gz
export GOPATH=/opt/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
cat <<-EOF>> /root/.bashrc
export GOPATH=/opt/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
EOF

## Yanic Installation
go get -v -u github.com/FreifunkBremen/yanic

### Yanic cfg setzen
cd /etc
wget https://raw.githubusercontent.com/Tarnatos/kiel-yanic-cfg/master/etc/yanic.conf

###Log Files
mkdir -p /var/lib/yanic
mkdir /var/log/yanic
touch /var/log/yanic/yanic.log
touch /etc/logrotate.d/yanic
cat <<-EOF>> /etc/logrotate.d/yanic
/var/log/yanic/*.log
{
 rotate 1
 daily
 missingok
 sharedscripts
 compress
 postrotate
   invoke-rc.d rsyslog rotate > /dev/null
 endscript
}
EOF

useradd yanic

### Ausgabe Verzeichnise erstellen
mkdir -p /var/www/html/meshviewer/data/
chown yanic /var/log/yanic.log /var/lib/yanic /var/www/html/meshviewer /var/www/html/meshviewer/data
cp /opt/go/src/github.com/FreifunkBremen/yanic/contrib/init/linux-systemd/yanic.service /lib/systemd/system/

### systemd Dienst aktivieren
systemctl daemon-reload
systemctl enable yanic
systemctl start yanic

### iptables Regeln setzen
touch /etc/iptables.d/500-Allow-respondd
cat <<-EOF>> /etc/iptables.d/500-Allow-respondd
# Allow Service respondd
ip46tables -A wan-input -p udp -m udp --dport 45123    -j ACCEPT
ip46tables -A mesh-input -p udp -m udp --dport 45123    -j ACCEPT
EOF

build-firewall
