#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "           Automatic Installer for Nibiru Chain ID : nibiru-itn-1 ";
echo -e "\e[0m"

sleep 1

# Variable
NIBI_WALLET=wallet
NIBI=nibid
NIBI_ID=nibiru-itn-1
NIBI_FOLDER=.nibid
NIBI_VER=v0.19.2
NIBI_REPO=https://github.com/NibiruChain/nibiru.git
NIBI_GENESIS=https://snapshot.yeksin.net/nibiru/genesis.json
NIBI_ADDRBOOK=https://ss-t.nibiru.nodestake.top/addrbook.json
NIBI_DENOM=unibi
NIBI_PORT=05

echo "export NIBI_WALLET=${NIBI_WALLET}" >> $HOME/.bash_profile
echo "export NIBI=${NIBI}" >> $HOME/.bash_profile
echo "export NIBI_ID=${NIBI_ID}" >> $HOME/.bash_profile
echo "export NIBI_FOLDER=${NIBI_FOLDER}" >> $HOME/.bash_profile
echo "export NIBI_VER=${NIBI_VER}" >> $HOME/.bash_profile
echo "export NIBI_REPO=${NIBI_REPO}" >> $HOME/.bash_profile
echo "export NIBI_GENESIS=${NIBI_GENESIS}" >> $HOME/.bash_profile
echo "export NIBI_ADDRBOOK=${NIBI_ADDRBOOK}" >> $HOME/.bash_profile
echo "export NIBI_DENOM=${NIBI_DENOM}" >> $HOME/.bash_profile
echo "export NIBI_PORT=${NIBI_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NIBI_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " NIBI_NODENAME
        echo 'export NIBI_NODENAME='$NIBI_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$NIBI_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$NIBI_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$NIBI_PORT\e[0m"
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
rm -rf $NIBI
git clone $NIBI_REPO
cd nibiru
git checkout $NIBI_VER
make install

# Init generation
$NIBI config chain-id $NIBI_ID
$NIBI config keyring-backend test
$NIBI config node tcp://localhost:${NIBI_PORT}657
$NIBI init $NIBI_NODENAME --chain-id $NIBI_ID

# Set peers and seeds
PEERS="e2b8b9f3106d669fe6f3b49e0eee0c5de818917e@213.239.217.52:32656,930b1eb3f0e57b97574ed44cb53b69fb65722786@144.76.30.36:15662,ad002a4592e7bcdfff31eedd8cee7763b39601e7@65.109.122.105:36656,4a81486786a7c744691dc500360efcdaf22f0840@15.235.46.50:26656,68874e60acc2b864959ab97e651ff767db47a2ea@65.108.140.220:26656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:39656"
SEEDS="a431d3d1b451629a21799963d9eb10d83e261d2c@seed-1.itn-1.nibiru.fi:26656,6a78a2a5f19c93661a493ecbe69afc72b5c54117@seed-2.itn-1.nibiru.fi:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$NIBI_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$NIBI_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $NIBI_GENESIS > $HOME/$NIBI_FOLDER/config/genesis.json
curl -Ls $NIBI_ADDRBOOK > $HOME/$NIBI_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NIBI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NIBI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NIBI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NIBI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NIBI_PORT}660\"%" $HOME/$NIBI_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NIBI_PORT}317\"%; s%^address = \":8080\"%address = \":${NIBI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NIBI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NIBI_PORT}091\"%" $HOME/$NIBI_FOLDER/config/app.toml

# Set Config Pruning
sed -i -e "s/^pruning *=.*/pruning = \"nothing\"/" $HOME/.nibid/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.nibid/config/config.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001$NIBI_DENOM\"/" $HOME/$NIBI_FOLDER/config/app.toml

# Enable snapshots
$NIBI tendermint unsafe-reset-all --home $HOME/$NIBI_FOLDER --keep-addr-book
curl -L https://nibiru-t.service.indonode.net/nibiru-snapshot.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.nibid

# Create Service
sudo tee /etc/systemd/system/$NIBI.service > /dev/null <<EOF
[Unit]
Description=$NIBI
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $NIBI) start --home $HOME/$NIBI_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $NIBI
sudo systemctl start $NIBI

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $NIBI -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${NIBI_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
