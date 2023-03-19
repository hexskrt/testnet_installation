#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "    Automatic Installer for Bonus Blockchain | Chain ID : blocktopia-01 ";
echo -e "\e[0m"
sleep 1

# Variable
BONUS_WALLET=wallet
BONUS=bonus-blockd
BONUS_ID=blocktopia-01
BONUS_FOLDER=.bonusblock
BONUS_REPO=https://github.com/BBlockLabs/BonusBlock-chain
BONUS_DENOM=ubonus
BONUS_PORT=13

echo "export BONUS_WALLET=${BONUS_WALLET}" >> $HOME/.bash_profile
echo "export BONUS=${BONUS}" >> $HOME/.bash_profile
echo "export BONUS_ID=${BONUS_ID}" >> $HOME/.bash_profile
echo "export BONUS_FOLDER=${BONUS_FOLDER}" >> $HOME/.bash_profile
echo "export BONUS_VER=${BONUS_VER}" >> $HOME/.bash_profile
echo "export BONUS_REPO=${BONUS_REPO}" >> $HOME/.bash_profile
echo "export BONUS_DENOM=${BONUS_DENOM}" >> $HOME/.bash_profile
echo "export BONUS_PORT=${BONUS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $BONUS_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " BONUS_NODENAME
        echo 'export BONUS_NODENAME='$BONUS_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$BONUS_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$BONUS_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$BONUS_PORT\e[0m"
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

# Get version of Bonus Blockchain
cd $HOME
rm -rf .bonusblock 
cd $HOME
git clone $BONUS_REPO
cd BonusBlock-chain
make build

$BONUS config chain-id $BONUS_ID
$BONUS config keyring-backend test
$BONUS config node tcp://localhost:${BONUS_PORT}657
$BONUS init $BONUS_NODENAME --chain-id $BONUS_ID

# Set peers and seeds
SEEDS="e5e04918240cfe63e20059a8abcbe62f7eb05036@bonusblock-testnet-p2p.alter.network:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$BONUS_FOLDER/config/config.toml

# Download genesis
rm ~/$BONUS_FOLDER/config/genesis.json
curl https://bonusblock-testnet.alter.network/genesis? | jq '.result.genesis' > ~/.bonusblock/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${BONUS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${BONUS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${BONUS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${BONUS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${BONUS_PORT}660\"%" $HOME/$BONUS_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${BONUS_PORT}317\"%; s%^address = \":8080\"%address = \":${BONUS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${BONUS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${BONUS_PORT}091\"%" $HOME/$BONUS_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$BONUS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$BONUS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$BONUS_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$BONUS_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$BONUS_DENOM\"/" $HOME/$BONUS_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$BONUS_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$BONUS_FOLDER/config/app.toml

# Enable Snapshot
$BONUS tendermint unsafe-reset-all --home $HOME/$BONUS_FOLDER
curl -L http://snapcrot.hexskrt.net/bonus-block/bonus-block.latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/$BONUS_FOLDER
# Create Service
sudo tee /etc/systemd/system/$BONUS.service > /dev/null <<EOF
[Unit]
Description=$BONUS
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $BONUS) start --home $HOME/$BONUS_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $BONUS
sudo systemctl start $BONUS

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $BONUS -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${BONUS_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
