#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "                 Automatic Installer for SAO Network ";
echo -e "\e[0m"

sleep 1

# Variable
SAO_WALLET=wallet
SAO=saod
SAO_ID=sao-testnet1
SAO_FOLDER=.sao
SAO_VER=v0.1.3
SAO_REPO=https://github.com/SaoNetwork/sao-consensus.git
SAO_DENOM=sao
SAO_PORT=09

echo "export SAO_WALLET=${SAO_WALLET}" >> $HOME/.bash_profile
echo "export SAO=${SAO}" >> $HOME/.bash_profile
echo "export SAO_ID=${SAO_ID}" >> $HOME/.bash_profile
echo "export SAO_FOLDER=${SAO_FOLDER}" >> $HOME/.bash_profile
echo "export SAO_VER=${SAO_VER}" >> $HOME/.bash_profile
echo "export SAO_REPO=${SAO_REPO}" >> $HOME/.bash_profile
echo "export SAO_DENOM=${SAO_DENOM}" >> $HOME/.bash_profile
echo "export SAO_PORT=${SAO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $SAO_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " SAO_NODENAME
        echo 'export SAO_NODENAME='$SAO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$SAO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$SAO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$SAO_PORT\e[0m"
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

# Get testnet version of sao network
cd $HOME
rm -rf $SAO
git clone $SAO_REPO
cd sao-consensus
git checkout $SAO_VER
make install
sudo mv ~/go/bin/saod /usr/local/bin/saod

# Init generation
$SAO config chain-id $SAO_ID
$SAO config keyring-backend test
$SAO config node tcp://localhost:${SAO_PORT}657
$SAO init sao-testnet --chain-id $SAO_ID

# Set peers and seeds
SEEDS="59cef823c1a426f15eb9e688287cd1bc2b6ea42d@152.70.126.187:26656,a5298771c624a376fdb83c48cc6c630e58092c62@192.18.136.151:26656,af7259853f202391e624c612ff9d3de1142b4ca4@52.77.248.130:26656,c196d06c9c37dee529ca167701e25f560a054d6d@3.35.136.39:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$SAO_FOLDER/config/config.toml

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SAO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SAO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SAO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SAO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SAO_PORT}660\"%" $HOME/$SAO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SAO_PORT}317\"%; s%^address = \":8080\"%address = \":${SAO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SAO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SAO_PORT}091\"%" $HOME/$SAO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$SAO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$SAO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$SAO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$SAO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001$SAO_DENOM\"/" $HOME/$SAO_FOLDER/config/app.toml

# Enable snapshots
$SAO tendermint unsafe-reset-all --home $HOME/$SAO_FOLDER --keep-addr-book
SNAP_NAME=$(curl -s https://ss-t.sao.nodestake.top/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://ss-t.sao.nodestake.top/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.sao

# Create Service
sudo tee /etc/systemd/system/$SAO.service > /dev/null <<EOF
[Unit]
Description=$SAO
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $SAO) start --home $HOME/$SAO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $SAO
sudo systemctl start $SAO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $SAO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${SAO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
