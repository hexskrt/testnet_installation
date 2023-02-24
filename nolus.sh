#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "              Cosmovisor Automatic Installer for NOLUS ";
echo -e "\e[0m"

sleep 1

# Variable
NLS_WALLET=wallet
NLS=nolusd
NLS_ID=nolus-rila
NLS_FOLDER=.nolus
NLS_VER=v0.1.43
NLS_REPO=https://github.com/Nolus-Protocol/nolus-core.git
NLS_GENESIS=https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/genesis.json
NLS_ADDRBOOK=https://raw.githubusercontent.com/obajay/nodes-Guides/main/Nolus/addrbook.json
NLS_DENOM=unls
NLS_PORT=39

echo "export NLS_WALLET=${NLS_WALLET}" >> $HOME/.bash_profile
echo "export NLS=${NLS}" >> $HOME/.bash_profile
echo "export NLS_ID=${NLS_ID}" >> $HOME/.bash_profile
echo "export NLS_FOLDER=${NLS_FOLDER}" >> $HOME/.bash_profile
echo "export NLS_VER=${NLS_VER}" >> $HOME/.bash_profile
echo "export NLS_REPO=${NLS_REPO}" >> $HOME/.bash_profile
echo "export NLS_GENESIS=${NLS_GENESIS}" >> $HOME/.bash_profile
echo "export NLS_ADDRBOOK=${NLS_ADDRBOOK}" >> $HOME/.bash_profile
echo "export NLS_DENOM=${NLS_DENOM}" >> $HOME/.bash_profile
echo "export NLS_PORT=${NLS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NLS_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " NLS_NODENAME
        echo 'export NLS_NODENAME='$NLS_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$NLS_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$NLS_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$NLS_PORT\e[0m"
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
rm -rf $NLS
git clone $NLS_REPO
cd babylon
git checkout $NLS_VER
make build
sudo mv build/$NLS /usr/bin/

# Init generation
$NLS config chain-id $NLS_ID
$NLS config keyring-backend test
$NLS config node tcp://localhost:${NLS_PORT}657
$NLS init $NLS_NODENAME --chain-id $NLS_ID

# Set peers and seeds
PEERS="56cee116ac477689df3b4d86cea5e49cfb450dda@54.246.232.38:26656,56f14005119e17ffb4ef3091886e6f7efd375bfd@34.241.107.0:26656,7f26067679b4323496319fda007a279b52387d77@63.35.222.83:26656,7f4a1876560d807bb049b2e0d0aa4c60cc83aa0a@63.32.88.49:26656,3889ba7efc588b6ec6bdef55a7295f3dd559ebd7@3.249.209.26:26656,de7b54f988a5d086656dcb588f079eb7367f6033@34.244.137.169:26656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$NLS_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$NLS_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $NLS_GENESIS > $HOME/$NLS_FOLDER/config/genesis.json
curl -Ls $NLS_ADDRBOOK > $HOME/$NLS_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NLS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NLS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NLS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NLS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NLS_PORT}660\"%" $HOME/$NLS_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NLS_PORT}317\"%; s%^address = \":8080\"%address = \":${NLS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NLS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NLS_PORT}091\"%" $HOME/$NLS_FOLDER/config/app.toml

# Set Config Pruning
sed -i -e "s/^pruning *=.*/pruning = \"nothing\"/" $HOME/.nolus/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.nolus/config/config.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001$NLS_DENOM\"/" $HOME/$NLS_FOLDER/config/app.toml

# Enable snapshots
$NLS tendermint unsafe-reset-all --home $HOME/$NLS_FOLDER --keep-addr-book

curl -o - -L http://nolus.snapshot.stavr.tech:1010/nolus/nolus-snap.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.nolus --strip-components 2

# Create Service
sudo tee /etc/systemd/system/$NLS.service > /dev/null <<EOF
[Unit]
Description=$NLS
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $NLS) start --home $HOME/$NLS_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $NLS
sudo systemctl start $NLS

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $NLS -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${NLS_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
