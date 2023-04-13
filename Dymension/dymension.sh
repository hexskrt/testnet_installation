#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "            Automatic Installer for Dymension Chain ID : 35-C";
echo -e "\e[0m"
sleep 1

# Variable
DYMENSION_WALLET=wallet
DYMENSION=dymd
DYMENSION_ID=35-C
DYMENSION_FOLDER=.dymension
DYMENSION_VER=v0.2.0-beta
DYMENSION_REPO=https://github.com/dymensionxyz/dymension
DYMENSION_DENOM=udym
DYMENSION_PORT=04
DYMENSION_GENESIS=https://snap.hexnodes.co/dymension/genesis.json
DYMENSION_ADDRBOOK=https://snap.hexnodes.co/dymension/addrbook.json

echo "export DYMENSION_WALLET=${DYMENSION_WALLET}" >> $HOME/.bash_profile
echo "export DYMENSION=${DYMENSION}" >> $HOME/.bash_profile
echo "export DYMENSION_ID=${DYMENSION_ID}" >> $HOME/.bash_profile
echo "export DYMENSION_FOLDER=${DYMENSION_FOLDER}" >> $HOME/.bash_profile
echo "export DYMENSION_VER=${DYMENSION_VER}" >> $HOME/.bash_profile
echo "export DYMENSION_REPO=${DYMENSION_REPO}" >> $HOME/.bash_profile
echo "export DYMENSION_DENOM=${DYMENSION_DENOM}" >> $HOME/.bash_profile
echo "export DYMENSION_PORT=${DYMENSION_PORT}" >> $HOME/.bash_profile
echo "export DYMENSION_GENESIS=${DYMENSION_GENESIS}" >> $HOME/.bash_profile
echo "export DYMENSION_ADDRBOOK=${DYMENSION_ADDRBOOK}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $DYMENSION_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " DYMENSION_NODENAME
        echo 'export DYMENSION_NODENAME='$DYMENSION_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$DYMENSION_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$DYMENSION_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$DYMENSION_PORT\e[0m"
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

# Get testnet version of dymension
cd $HOME
rm -rf dymension
git clone $DYMENSION_REPO --branch $DYMENSION_VER
cd dymension
make install

# Init generation
$DYMENSION config chain-id $DYMENSION_ID
$DYMENSION config keyring-backend test
$DYMENSION config node tcp://localhost:${DYMENSION_PORT}657
$DYMENSION init $DYMENSION_NODENAME --chain-id $DYMENSION_ID

# Set peers and seeds
PEERS="76fb074cb54791afa399979ca863da211404bad6@dymension-testnet.nodejumper.io:27656,290ec1fc5cc5667d4e072cf336758d744d291ef1@65.109.104.118:26656,139340424dddf85e54e0a54179d06875013e1e39@65.109.87.88:24656,db0264c412618949ce3a63cb07328d027e433372@146.19.24.101:26646,9111fd409e5521470b9b33a46009f5e53c646a0d@178.62.81.245:45656,e6ea3444ac85302c336000ac036f4d86b97b3d3e@38.146.3.199:20556,b473a649e58b49bc62b557e94d35a2c8c0ee9375@95.214.53.46:36656,d8b1bcfc123e63b24d0ebf86ab674a0fc5cb3b06@51.159.97.212:26656,1bffcd1690806b5796415ff72f02157ce048bcdd@144.76.67.53:2580,7fc44e2651006fb2ddb4a56132e738da2845715f@65.108.6.45:61256,55f233c7c4bea21a47d266921ca5fce657f3adf7@168.119.240.200:26656,8f84d324a2d266e612d06db4a793b0d001ee62a0@38.146.3.200:20556,e8a706e3a81a36a6dded6cc02eabaf5d355f4c1d@80.79.5.171:28656,d4a66d01b1d109d842a7f1d51f541033c653ea03@116.202.227.117:46656,0d30a0790a216d01c9759ab48192d9154381e6c0@136.243.88.91:3240,0ee31ef97ba6b6c13b25b5c528163f2092821c2d@65.21.132.27:24856,b8d08951d68da03af8f9272bf77684811197c289@95.216.41.160:26656,c6cdcc7f8e1a33f864956a8201c304741411f219@3.214.163.125:26656,cb1cc6b4c48b3e311f18b606c663c2dc0fb89b75@74.96.207.62:26656,a85420b25181bdb9b3a38741c48dafd5fb3b922f@209.34.205.57:26656,1f2b68851c8b17ed796e67af3c6734343e8a2684@65.108.97.58:2446,09927421cd3aa47bc81f8f981e15c547bc490121@5.9.83.110:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@195.3.220.136:27086,cb6ae22e1e89d029c55f2cb400b0caa19cbe5523@138.197.153.254:26603,f9d5e36ecc66b48f9fb940a778dd0c3b6b7c3d1d@65.109.106.211:26656,1ed89bd1d280c4c6eb7d9134bb238d97fbb3f4b2@88.99.104.180:36656,9e1ea4938f0112c1477827344e2f9d0792710575@185.252.232.189:30656,2d05753b4f5ac3bcd824afd96ea268d9c32ed84d@65.108.132.239:56656,747d05bfe9f3e0c2e0462ac351c577699e1d9b8c@207.244.244.194:26656,17d3ee8e5c033978a2d3c4ca862d8cc31dc97f3c@185.188.249.172:26656,4e2984edd9da237b189d51a49f36dfb03b2d23f1@65.108.105.48:20556,bb8615bb51139c05fd59020fc2aa7eac210690b4@135.181.221.186:27656,ba2ef45240cc997443df795b801a34602ba68b55@65.109.92.241:17886,bc16317771f51fc7f59550dae3f88140ab1f29af@65.109.106.179:20556,965694b051742c2da0ea66502dd9bfeea38de265@198.244.228.235:26656,f3ef396121156b51fd9ae503047481ffaa719e08@135.181.205.220:26656,b08d4d6b8efdea3c09d5418e170935356d01f1a9@65.108.98.41:26656,a4b27ddb9e126d1debafeef0a23ab60e4d5d8a14@95.216.2.219:26656,8da211209f9b84c6b9ce9f8d9226a22e35384dcb@65.109.82.249:36656,3a8bb83d5c5afb13ae2c1c3b91c97928e277f6a5@142.132.205.94:15658,f11d87d4d7ed4497b446b0071ca59096126da671@165.22.96.174:26656,af6787b3273dd60e0f809c7e5e2a2a9fd379045e@195.201.195.61:27656,f98c59000251fa5118c734eca5dc4d467f4c9065@45.147.248.14:46656,9755cab2585a2794453a5b396ef13b893393366f@65.108.212.224:46677,8e667c0759bfb20ec42b939956706301a4f2a10d@65.109.92.8:26656,281190aa44ca82fb47afe60ba1a8902bae469b2a@88.99.164.158:17086,babc3f3f7804933265ec9c40ad94f4da8e9e0017@38.146.3.101:20556,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@176.9.82.221:20556"
SEEDS="c6cdcc7f8e1a33f864956a8201c304741411f219@3.214.163.125:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$DYMENSION_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$DYMENSION_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $DYMENSION_GENESIS > $HOME/$DYMENSION_FOLDER/config/genesis.json
curl -Ls $DYMENSION_ADDRBOOK > $HOME/$DYMENSION_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DYMENSION_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DYMENSION_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DYMENSION_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DYMENSION_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DYMENSION_PORT}660\"%" $HOME/$DYMENSION_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DYMENSION_PORT}317\"%; s%^address = \":8080\"%address = \":${DYMENSION_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DYMENSION_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DYMENSION_PORT}091\"%" $HOME/$DYMENSION_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$DYMENSION_DENOM\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

# Enable snapshot
$DYMENSION tendermint unsafe-reset-all --home $HOME/$DYMENSION_FOLDER --keep-addr-book
curl -L https://snap.hexnodes.co/dymension/dymension.latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/$DYMENSION_FOLDER

# Create Service
sudo tee /etc/systemd/system/$DYMENSION.service > /dev/null <<EOF
[Unit]
Description=$DYMENSION
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $DYMENSION) start --home $HOME/$DYMENSION_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $DYMENSION
sudo systemctl start $DYMENSION

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $DYMENSION -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${DYMENSION_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
