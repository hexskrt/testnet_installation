#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "        Automatic Installer for Terp Network | Chain ID : athena-4 ";
echo -e "\e[0m"
sleep 1

# Variable
TERP_WALLET=wallet
TERP=terpd
TERP_ID=athena-4
TERP_FOLDER=.terp
TERP_VERSION=v0.4.0
TERP_REPO=https://github.com/terpnetwork/terp-core.git
TERP_ADDRBOOK=https://snap.hexnodes.co/terp/addrbook.json
TERP_GENESIS=https://snap.hexnodes.co/terp/genesis.json
TERP_DENOM=uterpx
TERP_PORT=16

echo "export TERP_WALLET=${TERP_WALLET}" >> $HOME/.bash_profile
echo "export TERP=${TERP}" >> $HOME/.bash_profile
echo "export TERP_ID=${TERP_ID}" >> $HOME/.bash_profile
echo "export TERP_FOLDER=${TERP_FOLDER}" >> $HOME/.bash_profile
echo "export TERP_VER=${TERP_VER}" >> $HOME/.bash_profile
echo "export TERP_REPO=${TERP_REPO}" >> $HOME/.bash_profile
echo "export TERP_DENOM=${TERP_DENOM}" >> $HOME/.bash_profile
echo "export TERP_PORT=${TERP_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $TERP_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " TERP_NODENAME
        echo 'export TERP_NODENAME='$TERP_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$TERP_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$TERP_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$TERP_PORT\e[0m"
echo ""

# Install GO
ver="1.19.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get version of TERPIO Network
cd $HOME
rm -rf terp-core
cd $HOME
git clone $TERP_REPO
cd terp-core
git checkout $TERP_VERSION
make install

$TERP config chain-id $TERP_ID
$TERP config keyring-backend test
$TERP config node tcp://localhost:${TERP_PORT}657
$TERP init $TERP_NODENAME --chain-id $TERP_ID

# Set peers and seeds
SEEDS="a6ee57fb457f71530d165afd1901d0d62cd7d7e0@terp-testnet-seed.itrocket.net:13656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$TERP_FOLDER/config/config.toml

# Download Genesis & Addrbook
curl -Ls $TERP_GENESIS > $HOME/$TERP_FOLDER/config/genesis.json
curl -Ls $TERP_ADDRBOOK > $HOME/$TERP_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${TERP_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${TERP_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${TERP_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${TERP_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${TERP_PORT}660\"%" $HOME/$TERP_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${TERP_PORT}317\"%; s%^address = \":8080\"%address = \":${TERP_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${TERP_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${TERP_PORT}091\"%" $HOME/$TERP_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$TERP_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$TERP_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$TERP_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$TERP_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$TERP_DENOM\"/" $HOME/$TERP_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$TERP_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$TERP_FOLDER/config/app.toml

# Enable Snapshot
$TERP tendermint unsafe-reset-all --home $HOME/$TERP_FOLDER --keep-addr-book
curl -L https://snap.hexnodes.co/terp/terp.latest.tar.lz4  | tar -Ilz4 -xf - -C $HOME/$TERP_FOLDER

# Create Service
sudo tee /etc/systemd/system/$TERP.service > /dev/null <<EOF
[Unit]
Description=$TERP
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $TERP) start --home $HOME/$TERP_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $TERP
sudo systemctl start $TERP

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $TERP -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${TERP_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
