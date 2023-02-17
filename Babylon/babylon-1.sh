#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "      Automatic Installer for BBNlon Chain | chain id : bbn-test1";
echo -e "\e[0m"
sleep 1

# Variable
BBN_WALLET=wallet
BBN=babylond
BBN_ID=bbn-test1
BBN_FOLDER=.babylond
BBN_VER=v0.5.0
BBN_REPO=https://github.com/BBNlonchain/BBNlon.git
BBN_DENOM=ubbn
BBN_PORT=03

echo "export BBN_WALLET=${BBN_WALLET}" >> $HOME/.bash_profile
echo "export BBN=${BBN}" >> $HOME/.bash_profile
echo "export BBN_ID=${BBN_ID}" >> $HOME/.bash_profile
echo "export BBN_FOLDER=${BBN_FOLDER}" >> $HOME/.bash_profile
echo "export BBN_VER=${BBN_VER}" >> $HOME/.bash_profile
echo "export BBN_REPO=${BBN_REPO}" >> $HOME/.bash_profile
echo "export BBN_DENOM=${BBN_DENOM}" >> $HOME/.bash_profile
echo "export BBN_PORT=${BBN_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $BBN_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " BBN_NODENAME
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

# Get testnet version of babylond
cd $HOME
rm -rf babylond
git clone $BBN_REPO
cd babylond
git checkout $BBN_VER
make build
sudo mv build/$BBN /usr/bin/

# Init generation
$BBN config chain-id $BBN_ID
$BBN config keyring-backend file
$BBN config node tcp://localhost:${BBN_PORT}657
$BBN init $BBN_NODENAME --chain-id $BBN_ID

# Set peers and seeds
PEERS="88bed747abef320552d84d02947d0dd2b6d9c71c@babylon-testnet.nodejumper.io:44656,0c5e0d543408a1082140f8bcce87d2021e88a1ac@144.76.109.221:33656,a4f76dddb6bdb195a0e49be82a3fd789d98631df@65.109.85.170:55656,fb4f8b0cf32bcf41fd2330c8d632f1d95004b127@54.83.122.43:26656,69ef025bead8bc5d9ad5297be2d8e6d01a864227@65.109.89.5:33656,c48276582fbd884a57bd481d2b5c1503c7b73e92@54.224.66.12:26656,b531acac8945962606025db892d86bb0bf0872af@3.93.71.208:26656,ed9df3c70f5905307867d4817b95a1839fdf1655@154.53.56.176:27656,cd9d96f554e7298a8d1f1a94489f7a51520f01ff@142.132.152.46:47656,e3f9ccbfc86011bb2bd6c2756b2c8b8dc4c8eb97@54.81.138.3:26656,d54157138c8b26d8eabf4b0d9e01b2b5d9e38267@54.234.206.250:26656,617b10a9ea1c97b8230ccb70e1fb4ecef1b46601@18.212.224.149:26656,20667369008eed7963655305f02f1b0af79b53ee@35.200.42.151:26656,1400847b76e57c13e49ff1bfbcce7e71865dde7f@65.109.92.240:17896,03ce5e1b5be3c9a81517d415f65378943996c864@18.207.168.204:26656,2c06e6d7ae970824dd3da1ac352c6f2fa6bb9f4b@38.242.241.126:26656,a4acf4478c64011d9351edccbb38e2c7a567a0bc@185.188.249.17:26656,17f2f17cf7e471eff3fd32f0e0b966a12d5f8366@65.109.117.159:14656,1d0c78d6945ac4007dafef2a130e532c07b806d2@65.108.105.48:20656,07d1b69e4dc56d46dabe8f5eb277fcde0c6c9d1e@23.88.5.169:17656,c15ea9cfa8928886c2d2a573bc20f14871168b22@185.242.112.143:16655,42dd05c43fa9e51cfabc6a2ab0afa9044b123cc6@34.201.34.29:26656,b4ccb4af8c4e226e5844065197dfbe013690758b@65.108.233.220:14656,f136d7e7788c8e9c9c4784703f158029ffdb70b5@65.108.200.248:55706,9bb2b717165a7a2f0cad69051c89d9f118b72537@81.196.253.241:40656,b10105846b4f9086b9f9245df4841a4bb7c6ba7b@65.108.197.169:14656,b2c3a12aba7cbfa34cdb45a5b6f133fb7f251817@65.109.85.225:4310,c2bc08c7b0292f7072b1530ffc03ebf69563f518@95.216.39.183:27656,5e8d38d4f4f02e3cc54babb930218f544992d3e4@65.109.61.116:19656,b068b6464f706e53c8cdbbbdf964477f9a589c6a@65.108.237.233:31656,923a09bffb20553869932b96a708756acc33872f@65.109.52.169:20656,ec8cdf31d3065c52922566e2729bf843eb5e7b39@213.239.217.52:42656,0e64bf0adab64d4ef33522441c0ec34d0147e8bd@65.108.200.60:25656,7cf424ff2939501d9ab9296889e5ab66c826527a@65.109.85.221:4310,c4c473143dc8b1a26cf62074572e501b6444aed8@193.203.15.130:26656,a5fabac19c732bf7d814cf22e7ffc23113dc9606@34.238.169.221:26656,87b3d99aaa2134815fd8ce389011407c6d4ddd8f@113.23.69.80:26656,ae5b89a8f1934e45ad3698671005a56623f04111@213.239.207.165:29056,a8051774e809d8dc14673bb245abc0fc48a3f684@5.9.122.49:14656,cfe00b7663afd3bc9b4749720d5b0a5b7ad43784@207.244.232.82:26656,aa3ffeb7fa6c82c85104038da52f18689ed8a1e5@65.109.63.110:14656,e98cc273ce0ec58d278807179001fcb386ba550b@141.95.97.28:15556,f71a8fe9aa8f0e423dea7c98463f5d9a47549284@184.174.32.227:26656,3d49baa48472bb8d7d4b73272ead1047a6933c67@195.3.222.189:33656,539bbebeb0d13ac22db640b102235f7e4f00856d@104.244.208.243:20656,c2abdd62b87e83d4ca9cf5427e3d9dd71f53cc6d@148.113.159.123:36656,0100cbf147f512b81cd01268463bd71ab3e55138@65.109.85.226:4310,b53302c8887d4bd57799992592a2280987d3f213@95.217.144.107:20656"
SEEDS="03ce5e1b5be3c9a81517d415f65378943996c864@18.207.168.204:26656,a5fabac19c732bf7d814cf22e7ffc23113dc9606@34.238.169.221:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$BBN_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$BBN_FOLDER/config/config.toml

# Create file genesis.json
touch $HOME/$BBN_FOLDER/config/genesis.json

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

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$BBN_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$BBN_FOLDER/config/app.toml

# Enable state sync
$BBN tendermint unsafe-reset-all --home $HOME/$BBN_FOLDER

SNAP_RPC="https://babylon-testnet.nodejumper.io:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$BBN_FOLDER/config/config.toml

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
