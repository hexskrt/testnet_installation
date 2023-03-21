#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "                Automatic Installer for Nois Network";
echo -e "\e[0m"

sleep 1

# Variable
NOIS_WALLET=wallet
NOIS=noisd
NOIS_ID=nois-testnet-004
NOIS_FOLDER=.noisd
NOIS_VER=v0.6.0
NOIS_REPO=https://github.com/noislabs/full-node.git
NOIS_GENESIS=https://raw.githubusercontent.com/noislabs/testnets/main/nois-testnet-004/genesis.json
NOIS_DENOM=unois
NOIS_PORT=13

echo "export NOIS_WALLET=${NOIS_WALLET}" >> $HOME/.bash_profile
echo "export NOIS=${NOIS}" >> $HOME/.bash_profile
echo "export NOIS_ID=${NOIS_ID}" >> $HOME/.bash_profile
echo "export NOIS_FOLDER=${NOIS_FOLDER}" >> $HOME/.bash_profile
echo "export NOIS_VER=${NOIS_VER}" >> $HOME/.bash_profile
echo "export NOIS_REPO=${NOIS_REPO}" >> $HOME/.bash_profile
echo "export NOIS_GENESIS=${NOIS_GENESIS}" >> $HOME/.bash_profile
echo "export NOIS_ADDRBOOK=${NOIS_ADDRBOOK}" >> $HOME/.bash_profile
echo "export NOIS_DENOM=${NOIS_DENOM}" >> $HOME/.bash_profile
echo "export NOIS_PORT=${NOIS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NOIS_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " NOIS_NODENAME
        echo 'export NOIS_NODENAME='$NOIS_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$NOIS_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$NOIS_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$NOIS_PORT\e[0m"
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

# Get testnet version of Nois Network
cd $HOME
rm -rf $NOIS
git clone $NOIS_REPO
cd $NOIS
git checkout $NOIS_VER
make install

# Init generation
$NOIS config chain-id $NOIS_ID
$NOIS config keyring-backend test
$NOIS config node tcp://localhost:${NOIS_PORT}657
$NOIS init $NOIS_NODENAME --chain-id $NOIS_ID

# Set peers and seeds
PEERS=""
SEEDS="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:17356"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$NOIS_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$NOIS_FOLDER/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/$NOIS_FOLDER/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/$NOIS_FOLDER/config/config.toml
sed -i 's/^timeout_propose =.*$/timeout_propose = "2000ms"/' $NOIS_FOLDER/config.toml \
  && sed -i 's/^timeout_propose_delta =.*$/timeout_propose_delta = "500ms"/' $NOIS_FOLDER/config.toml \
  && sed -i 's/^timeout_prevote =.*$/timeout_prevote = "1s"/' $NOIS_FOLDER/config.toml \
  && sed -i 's/^timeout_prevote_delta =.*$/timeout_prevote_delta = "500ms"/' $NOIS_FOLDER/config.toml \
  && sed -i 's/^timeout_precommit =.*$/timeout_precommit = "1s"/' $NOIS_FOLDER/config.toml \
  && sed -i 's/^timeout_precommit_delta =.*$/timeout_precommit_delta = "500ms"/' $NOIS_FOLDER/config.toml \
  && sed -i 's/^timeout_commit =.*$/timeout_commit = "1800ms"/' $NOIS_FOLDER/config.toml

# Download genesis and addrbook
curl -Ls $NOIS_GENESIS > $HOME/$NOIS_FOLDER/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NOIS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NOIS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NOIS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NOIS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NOIS_PORT}660\"%" $HOME/$NOIS_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NOIS_PORT}317\"%; s%^address = \":8080\"%address = \":${NOIS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NOIS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NOIS_PORT}091\"%" $HOME/$NOIS_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$NOIS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$NOIS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$NOIS_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$NOIS_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$NOIS_DENOM\"/" $HOME/$NOIS_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$NOIS_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$NOIS_FOLDER/config/app.toml

# Create Service
sudo tee /etc/systemd/system/$NOIS.service > /dev/null <<EOF
[Unit]
Description=$NOIS
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $NOIS) start --home $HOME/$NOIS_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $NOIS
sudo systemctl start $NOIS

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $NOIS -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${NOIS_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
