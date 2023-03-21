#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "      Automatic Installer for Babylon Chain | chain id : bbn-test1";
echo -e "\e[0m"
sleep 1

# Variable
BBN_WALLET=wallet
BBN=babylond
BBN_ID=bbn-test1
BBN_FOLDER=.babylond
BBN_VER=v0.5.0
BBN_REPO=https://github.com/babylonchain/babylon
BBN_GENESIS=https://snapshot.yeksin.net/babylon/genesis.json
BBN_ADDRBOOK=https://snapshots1-testnet.nodejumper.io/babylon-testnet/addrbook.json
BBN_DENOM=ubbn
BBN_PORT=02

echo "export BBN_WALLET=${BBN_WALLET}" >> $HOME/.bash_profile
echo "export BBN=${BBN}" >> $HOME/.bash_profile
echo "export BBN_ID=${BBN_ID}" >> $HOME/.bash_profile
echo "export BBN_FOLDER=${BBN_FOLDER}" >> $HOME/.bash_profile
echo "export BBN_VER=${BBN_VER}" >> $HOME/.bash_profile
echo "export BBN_REPO=${BBN_REPO}" >> $HOME/.bash_profile
echo "export BBN_GENESIS=${BBN_GENESIS}" >> $HOME/.bash_profile
echo "export BBN_ADDRBOOK=${BBN_ADDRBOOK}" >> $HOME/.bash_profile
echo "export BBN_DENOM=${BBN_DENOM}" >> $HOME/.bash_profile
echo "export BBN_PORT=${BBN_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $BBN_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " BBN_NODENAME
        echo 'export BBN_NODENAME='$BBN_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$BBN_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$BBN_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$BBN_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get testnet version of andromeda
cd $HOME
rm -rf $BBN
git clone $BBN_REPO
cd babylon
git checkout $BBN_VER
make build
sudo mv build/$BBN /usr/bin/

# Init generation
$BBN config chain-id $BBN_ID
$BBN config keyring-backend test
$BBN config node tcp://localhost:${BBN_PORT}657
$BBN init $BBN_NODENAME --chain-id $BBN_ID

# Set peers and seeds
PEERS=""
SEEDS="03ce5e1b5be3c9a81517d415f65378943996c864@18.207.168.204:26656,a5fabac19c732bf7d814cf22e7ffc23113dc9606@34.238.169.221:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$BBN_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$BBN_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $BBN_GENESIS > $HOME/$BBN_FOLDER/config/genesis.json
curl -Ls $BBN_ADDRBOOK > $HOME/$BBN_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${BBN_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${BBN_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${BBN_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${BBN_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${BBN_PORT}660\"%" $HOME/$BBN_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${BBN_PORT}317\"%; s%^address = \":8080\"%address = \":${BBN_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${BBN_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${BBN_PORT}091\"%" $HOME/$BBN_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$BBN_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$BBN_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$BBN_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$BBN_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001$BBN_DENOM\"/" $HOME/$BBN_FOLDER/config/app.toml

# Set key name
sed -i 's|^key-name *=.*|key-name = "val-key"|g' $HOME/$BBN_FOLDER/config/app.toml

# Set checkpoint tag
sed -i 's|^checkpoint-tag *=.*|checkpoint-tag = "bbn0"|g' $HOME/$BBN_FOLDER/config/app.toml

# Set timeout commit
sed -i 's|^timeout_commit *=.*|timeout_commit = "10s"|g' $HOME/$BBN_FOLDER/config/config.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$BBN_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$ANDRO_FOLDER/config/app.toml
$BBN tendermint unsafe-reset-all --home $HOME/$BBN_FOLDER --keep-addr-book

SNAP_RPC="https://rpc-babylon.sxlzptprjkt.xyz:443"
STATESYNC_PEERS="4ffd7f9202c58df4afec210f22da732023e476c8@46.101.144.90:24656"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$BABY_FOLDER/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$STATESYNC_PEERS\"|" $HOME/$BABY_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$BBN.service > /dev/null <<EOF
[Unit]
Description=$BBN
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BBN) start --home $HOME/$BBN_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $BBN
sudo systemctl start $BBN

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $BBN -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${BBN_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
