#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "               Automatic Installer for BlockX v0.1.1-test ";
echo -e "\e[0m"

sleep 1

# Variable
BLOCK_WALLET=wallet
BLOCK=blockxd
BLOCK_ID=blockx_12345-2
BLOCK_FOLDER=.blockxd
BLOCK_VER=0.1.1-test
BLOCK_REPO=https://github.com/defi-ventures/blockx-node-public-compiled/releases/download/v9.0.0/blockxd
BLOCK_GENESIS=https://snap.nodexcapital.com/blockx/genesis.json
BLOCK_ADDRBOOK=https://snap.nodexcapital.com/blockx/addrbook.json
BLOCK_DENOM=abcx
BLOCK_PORT=11

echo "export BLOCK_WALLET=${BLOCK_WALLET}" >> $HOME/.bash_profile
echo "export BLOCK=${BLOCK}" >> $HOME/.bash_profile
echo "export BLOCK_ID=${BLOCK_ID}" >> $HOME/.bash_profile
echo "export BLOCK_FOLDER=${BLOCK_FOLDER}" >> $HOME/.bash_profile
echo "export BLOCK_VER=${BLOCK_VER}" >> $HOME/.bash_profile
echo "export BLOCK_REPO=${BLOCK_REPO}" >> $HOME/.bash_profile
echo "export BLOCK_GENESIS=${BLOCK_GENESIS}" >> $HOME/.bash_profile
echo "export BLOCK_ADDRBOOK=${BLOCK_ADDRBOOK}" >> $HOME/.bash_profile
echo "export BLOCK_DENOM=${BLOCK_DENOM}" >> $HOME/.bash_profile
echo "export BLOCK_PORT=${BLOCK_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $BLOCK_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " BLOCK_NODENAME
        echo 'export BLOCK_NODENAME='$BLOCK_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$BLOCK_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$BLOCK_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$BLOCK_PORT\e[0m"
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

# Get testnet version of BlockX
cd $HOME
curl -LO $BLOCK_REPO
chmod +x $BLOCK
sudo mv ~/go/bin/$BLOCK /usr/local/bin/$BLOCK

# Init generation
$BLOCK config chain-id $BLOCK_ID
$BLOCK config keyring-backend test
$BLOCK config node tcp://localhost:${BLOCK_PORT}657
$BLOCK init $BLOCK_NODENAME --chain-id $BLOCK_ID

# Set peers and seeds
PEERS="78dd8371dae4f081e76a32f9b5e90037737a341a@162.19.239.112:26656,d10fdd5873b1ae2d1ea3bc4de9753c7b2edf46b0@38.242.199.160:2936,85270df0f25f8a3c56884a5f7bfe0a02b49d13d7@193.34.213.6:26656,544b02ceacb0edcc043c7534db8516c20e25f12e@38.146.3.205:21456,dccf886659c4afcb0cd4895ccd9f2804c7e7e1cd@143.198.101.61:26656,49a5a62543f5fec60db42b00d9ebe192c3185e15@143.198.97.96:26656,4a7401f7d6daa39d331196d8cc179a4dcb11b5f9@143.198.110.221:26656"
SEEDS=""
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$BLOCK_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $BLOCK_GENESIS > $HOME/$BLOCK_FOLDER/config/genesis.json
curl -Ls $BLOCK_ADDRBOOK > $HOME/$BLOCK_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${BLOCK_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${BLOCK_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${BLOCK_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${BLOCK_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${BLOCK_PORT}660\"%" $HOME/$BLOCK_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${BLOCK_PORT}317\"%; s%^address = \":8080\"%address = \":${BLOCK_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${BLOCK_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${BLOCK_PORT}091\"%" $HOME/$BLOCK_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$BLOCK_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$BLOCK_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$BLOCK_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$BLOCK_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$BLOCK_DENOM\"/" $HOME/$BLOCK_FOLDER/config/app.toml
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$BLOCK_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$BLOCK_FOLDER/config/app.toml

# Enable Snapshot
$BLOCK tendermint unsafe-reset-all --home $HOME/$BLOCK_FOLDER
SNAP_NAME=$(curl -s https://ss-t.blockx.nodestake.top/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://ss-t.blockx.nodestake.top/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/$BLOCK_FOLDER

# Create Service
sudo tee /etc/systemd/system/$BLOCK.service > /dev/null <<EOF
[Unit]
Description=$BLOCK
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $BLOCK) start --home $HOME/$BLOCK_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $BLOCK
sudo systemctl start $BLOCK

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $BLOCK -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${BLOCK_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
