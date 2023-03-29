#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "     Automatic Installer for SGE Network | Chain ID : sge-network-2 ";
echo -e "\e[0m"
sleep 1

# Variable
SGE_WALLET=wallet
SGE=sged
SGE_ID=sge-network-2
SGE_FOLDER=.sge
SGE_REPO=https://github.com/sge-network/sge
SGE_VERSION=v0.0.5
SGE_GENESIS=https://snap.nodexcapital.com/sge/genesis.json
SGE_ADDRBOOK=https://snap.nodexcapital.com/sge/addrbook.json
SGE_DENOM=usge
SGE_PORT=20

echo "export SGE_WALLET=${SGE_WALLET}" >> $HOME/.bash_profile
echo "export SGE=${SGE}" >> $HOME/.bash_profile
echo "export SGE_ID=${SGE_ID}" >> $HOME/.bash_profile
echo "export SGE_FOLDER=${SGE_FOLDER}" >> $HOME/.bash_profile
echo "export SGE_VER=${SGE_VER}" >> $HOME/.bash_profile
echo "export SGE_REPO=${SGE_REPO}" >> $HOME/.bash_profile
echo "export SGE_DENOM=${SGE_DENOM}" >> $HOME/.bash_profile
echo "export SGE_PORT=${SGE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $SGE_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " SGE_NODENAME
        echo 'export SGE_NODENAME='$SGE_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$SGE_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$SGE_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$SGE_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.6"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get version of SGE Blockchain
cd $HOME
rm -rf $SGE_FOLDER
cd $HOME
git clone $SGE_REPO
cd sge
make install

$SGE config chain-id $SGE_ID
$SGE config keyring-backend test
$SGE config node tcp://localhost:${SGE_PORT}657
$SGE init $SGE_NODENAME --chain-id $SGE_ID

# Set peers and seeds
SEEDS="2ea9aea65aac71944093d9f90018997263e37c1b@rpc.sge-t.nodexcapital.com:23256"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$SGE_FOLDER/config/config.toml

# Download genesis
curl -Ls $SGE_GENESIS > $HOME/$SGE_FOLDER/config/genesis.json
curl -Ls $SGE_ADDRBOOK > $HOME/$SGE_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SGE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SGE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SGE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SGE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SGE_PORT}660\"%" $HOME/$SGE_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SGE_PORT}317\"%; s%^address = \":8080\"%address = \":${SGE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SGE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SGE_PORT}091\"%" $HOME/$SGE_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$SGE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$SGE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$SGE_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$SGE_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$SGE_DENOM\"/" $HOME/$SGE_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$SGE_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$SGE_FOLDER/config/app.toml

# Enable Snapshot
$SGE tendermint unsafe-reset-all --home $HOME/$SGE_FOLDER
curl -L https://snap.nodexcapital.com/sge/sge-latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/$SGE_FOLDER

# Create Service
sudo tee /etc/systemd/system/$SGE.service > /dev/null <<EOF
[Unit]
Description=$SGE
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $SGE) start --home $HOME/$SGE_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $SGE
sudo systemctl start $SGE

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $SGE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${SGE_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
