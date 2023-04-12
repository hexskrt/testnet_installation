#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "      Automatic Installer for Elys Network | Chain ID : elystestnet-1 ";
echo -e "\e[0m"
sleep 1

# Variable
ELYS_WALLET=wallet
ELYS=elysd
ELYS_ID=elystestnet-1
ELYS_FOLDER=.elys
ELYS_VERSION=v0.2.3
ELYS_REPO=https://github.com/elys-network/elys
ELYS_ADDRBOOK=https://snap.hexnodes.co/elys/addrbook.json
ELYS_GENESIS=https://snap.hexnodes.co/elys/genesis.json
ELYS_DENOM=uelys
ELYS_PORT=15

echo "export ELYS_WALLET=${ELYS_WALLET}" >> $HOME/.bash_profile
echo "export ELYS=${ELYS}" >> $HOME/.bash_profile
echo "export ELYS_ID=${ELYS_ID}" >> $HOME/.bash_profile
echo "export ELYS_FOLDER=${ELYS_FOLDER}" >> $HOME/.bash_profile
echo "export ELYS_VER=${ELYS_VER}" >> $HOME/.bash_profile
echo "export ELYS_REPO=${ELYS_REPO}" >> $HOME/.bash_profile
echo "export ELYS_DENOM=${ELYS_DENOM}" >> $HOME/.bash_profile
echo "export ELYS_PORT=${ELYS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $ELYS_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " ELYS_NODENAME
        echo 'export ELYS_NODENAME='$ELYS_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$ELYS_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$ELYS_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$ELYS_PORT\e[0m"
echo ""

# Install GO
ver="1.19.7"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get version of ELYSIO Network
cd $HOME
rm -rf ELYS-core
cd $HOME
git clone $ELYS_REPO
cd elys
git checkout $ELYS_VERSION
make build

cp $HOME/elys/build/* $HOME/go/bin/

$ELYS config chain-id $ELYS_ID
$ELYS config keyring-backend test
$ELYS config node tcp://localhost:${ELYS_PORT}657
$ELYS init $ELYS_NODENAME --chain-id $ELYS_ID

# Set peers and seeds
SEEDS="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:22056"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$ELYS_FOLDER/config/config.toml

# Download Genesis & Addrbook
curl -Ls $ELYS_GENESIS > $HOME/$ELYS_FOLDER/config/genesis.json
curl -Ls $ELYS_ADDRBOOK > $HOME/$ELYS_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ELYS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ELYS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ELYS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ELYS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ELYS_PORT}660\"%" $HOME/$ELYS_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ELYS_PORT}317\"%; s%^address = \":8080\"%address = \":${ELYS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ELYS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ELYS_PORT}091\"%" $HOME/$ELYS_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ELYS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ELYS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ELYS_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ELYS_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$ELYS_DENOM\"/" $HOME/$ELYS_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$ELYS_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$ELYS_FOLDER/config/app.toml

# Enable Snapshot
$ELYS tendermint unsafe-reset-all --home $HOME/$ELYS_FOLDER --keep-addr-book
curl -L https://snap.hexnodes.co/elys/elys.latest.tar.lz4  | tar -Ilz4 -xf - -C $HOME/$ELYS_FOLDER

# Create Service
sudo tee /etc/systemd/system/$ELYS.service > /dev/null <<EOF
[Unit]
Description=$ELYS
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $ELYS) start --home $HOME/$ELYS_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ELYS
sudo systemctl start $ELYS

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $ELYS -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${ELYS_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
