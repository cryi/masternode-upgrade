BLOCK_DIR=

#startup script
#disable the old one
systemctl disable --now snowgem.service

#remove old one
sudo rm /lib/systemd/system/snowgem.service

#create new one
sh -c "echo '[Unit]
Description=Snowgem daemon
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/root/snowgemd
WorkingDirectory=/root/.snowgem
User=root
KillMode=mixed
Restart=always
RestartSec=10
TimeoutStopSec=10
Nice=-20
ProtectSystem=full

[Install]
WantedBy=multi-user.target' >> /lib/systemd/system/snowgem.service"

killall -9 snowgemd

#remove old params files
rm ~/.snowgem-params -r

chmod +x ~/masternode-upgrade/fetch-params.sh

wget -N https://github.com/Snowgem/Snowgem/releases/download/3000450-20181208/snowgem-linux-3000450-20181208.zip -O ~/binary.zip
unzip -o ~/binary.zip -d ~

if [ ! -d ~/.snowgem/blocks ]; then
  wget -N https://cdn1.snowgem.org/blockchain_index.zip -O ~/blockchain.zip
  unzip -o ~/blockchain.zip -d ~/.snowgem
  rm ~/blockchain.zip
fi


cd ~

./masternode-upgrade/fetch-params.sh

chmod +x ~/snowgemd ~/snowgem-cli

#start
systemctl enable --now snowgem.service

echo "wait for 60 seconds"
sleep 60

./snowgem-cli getinfo