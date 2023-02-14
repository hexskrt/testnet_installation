#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;35m"
echo "  ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "  ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "  ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "  ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "  ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "Cosmovisor Automatic Installer for Game Of Terra Alliance chain id ordosd";
echo -e "\e[0m"

sleep 1

# Variable
TESTCORE_WALLET=wallet
TESTCORE=cored
BINARY=cosmovisor
TESTCORE_ID=coreum-testnet-1
TESTCORE_FOLDER=.core
TESTCORE_VER=v0.1.1
TESTCORE_BINARY=https://github.com/CoreumFoundation/coreum/releases/download
TESTCORE_BIN=cored-linux-amd64
TESTCORE_GENESIS=https://snap.nodexcapital.com/coreum/genesis.json
TESTCORE_ADDRBOOK=https://snap.nodexcapital.com/coreum/addrbook.json
TESTCORE_DENOM=utestcore
TESTCORE_PORT=21

echo "export TESTCORE_WALLET=${TESTCORE_WALLET}" >> $HOME/.bash_profile
echo "export TESTCORE=${TESTCORE}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export TESTCORE_ID=${TESTCORE_ID}" >> $HOME/.bash_profile
echo "export TESTCORE_FOLDER=${TESTCORE_FOLDER}" >> $HOME/.bash_profile
echo "export TESTCORE_VER=${TESTCORE_VER}" >> $HOME/.bash_profile
echo "export TESTCORE_BINARY=${TESTCORE_BINARY}" >> $HOME/.bash_profile
echo "export TESTCORE_BIN=${TESTCORE_BIN}" >> $HOME/.bash_profile
echo "export TESTCORE_GENESIS=${TESTCORE_GENESIS}" >> $HOME/.bash_profile
echo "export TESTCORE_ADDRBOOK=${TESTCORE_ADDRBOOK}" >> $HOME/.bash_profile
echo "export TESTCORE_DENOM=${TESTCORE_DENOM}" >> $HOME/.bash_profile
echo "export TESTCORE_PORT=${TESTCORE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $TESTCORE_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " TESTCORE_NODENAME
        echo 'export TESTCORE_NODENAME='$TESTCORE_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$TESTCORE_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$TESTCORE_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$TESTCORE_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install curl build-essential jq chrony lz4 -y

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

# Get testnet version of coreum
cd $HOME
curl -Ls $TESTCORE_BINARY/$TESTCORE_VER/$TESTCORE_BIN > $TESTCORE
chmod +x $TESTCORE
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/$BINARY/genesis/bin
mv $TESTCORE $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/$BINARY/genesis $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/$BINARY/current
sudo ln -s $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/$BINARY/current/bin/$TESTCORE /usr/bin/$TESTCORE

# Create Service
sudo tee /etc/systemd/system/$TESTCORE.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$TESTCORE_FOLDER/$TESTCORE_ID"
Environment="DAEMON_NAME=$TESTCORE"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register Service
sudo systemctl daemon-reload
sudo systemctl enable $TESTCORE

# Init generation
$TESTCORE config chain-id $TESTCORE_ID
$TESTCORE config keyring-backend file
$TESTCORE config node tcp://localhost:${TESTCORE_PORT}657
$TESTCORE init $TESTCORE_NODENAME --chain-id $TESTCORE_ID

# Set peers and seeds
PEERS="479773376706c0643289a365e84e440cced10bb9@146.190.81.135:21656,4b8d541efbb343effa1b5079de0b17d2566ac0fd@34.172.70.24:26656,051a07f1018cfdd6c24bebb3094179a6ceda2482@138.201.123.234:26656,1a3a573c53a4b90ab04eb47d160f4d3d6aa58000@35.233.117.165:26656,39a34cd4f1e908a88a726b2444c6a407f67e4229@158.160.59.199:26656,b2978432c0126f28a6be7d62892f8ded1e48d227@34.70.241.13:26656,7c0d4ce5ad561c3453e2e837d85c9745b76f7972@35.238.77.191:26656,5add70ec357311d07d10a730b4ec25107399e83c@5.196.7.58:26656,27450dc5adcebc84ccd831b42fcd73cb69970881@35.239.146.40:26656,abbeb588ad88176a8d7592cd8706ebbf7ef20cfe@185.241.151.197:26656,69d7028b7b3c40f64ea43208ecdd43e88c797fd6@34.69.126.231:26656,0aa5fa2507ada8a555d156920c0b09f0d633b0f9@34.173.227.148:26656"
SEEDS="64391878009b8804d90fda13805e45041f492155@35.232.157.206:26656,53f2367d8f8291af8e3b6ca60efded0675ff6314@34.29.15.170:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/config.toml

# Download genesis and addrbook
curl -Ls $TESTCORE_GENESIS > $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/genesis.json
curl -Ls $TESTCORE_ADDRBOOK > $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${TESTCORE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${TESTCORE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${TESTCORE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${TESTCORE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${TESTCORE_PORT}660\"%" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${TESTCORE_PORT}317\"%; s%^address = \":8080\"%address = \":${TESTCORE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${TESTCORE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${TESTCORE_PORT}091\"%" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$TESTCORE_DENOM\"/" $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/config/app.toml

# Enable snapshots
$TESTCORE tendermint unsafe-reset-all --keep-addr-book
rm -rf $HOME/$TESTCORE_FOLDER/$TESTCORE_ID/data
wget https://snap.nodexcapital.com/coreum/coreum-latest.tar.lz4
lz4 coreum-latest.tar.lz4
tar -xvf coreum-latest.tar
mv $TESTCORE_ID/data $HOME/$TESTCORE_FOLDER/$TESTCORE_ID
rm -f coreum-latest.tar.lz4
rm -f coreum-latest.tar
rm -rf coreum-testnet-1

#Start Service
sudo systemctl start $TESTCORE

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $TESTCORE\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $TESTCORE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${TESTCORE_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
