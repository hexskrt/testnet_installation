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
SOURCE=alliance
WALLET=wallet
BINARY=ordosd
CHAIN=ordos-1
FOLDER=.ordos
VERSION=v0.0.1-goa
DENOM=uord
COSMOVISOR=cosmovisor
REPO=https://github.com/terra-money/alliance
GENESIS=https://raw.githubusercontent.com/LavenderFive/game-of-alliance-2023/master/genesis/genesis-ordos.json
ADDRBOOK=https://raw.githubusercontent.com/LavenderFive/game-of-alliance-2023/master/addrbook/addrbook-ordos.json
PORT=10


echo "export SOURCE=${SOURCE}" >> $HOME/.bash_profile
echo "export WALLET=${WALLET}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export CHAIN=${CHAIN}" >> $HOME/.bash_profile
echo "export FOLDER=${FOLDER}" >> $HOME/.bash_profile
echo "export VERSION=${VERSION}" >> $HOME/.bash_profile
echo "export REPO=${REPO}" >> $HOME/.bash_profile
echo "export DENOM=${DENOM}" >> $HOME/.bash_profile
echo "export COSMOVISOR=${COSMOVISOR}" >> $HOME/.bash_profile
echo "export GENESIS=${GENESIS}" >> $HOME/.bash_profile
echo "export ADDRBOOK=${ADDRBOOK}" >> $HOME/.bash_profile
echo "export PORT=${PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NODENAME ]; then
	read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$NODENAME\e[0m"
echo -e "NODE CHAIN CHAIN  : \e[1m\e[31m$CHAIN\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade

# Install GO
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

# Get testnet version of Ordos

cd $HOME
rm -rf $SOURCE
git clone $REPO
cd $SOURCE
git checkout $VERSION
make build-alliance ACC_PREFIX=ordos
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$FOLDER/$COSMOVISOR/genesis/bin
mv build/$BINARY $HOME/$FOLDER/$COSMOVISOR/genesis/bin/
rm -rf build

# Create application symlinks
ln -s $HOME/$FOLDER/$COSMOVISOR/genesis $HOME/$FOLDER/$COSMOVISOR/current
sudo ln -s $HOME/$FOLDER/$COSMOVISOR/current/bin/$BINARY /usr/bin/$BINARY

# Init generation
$BINARY config chain-id $CHAIN
$BINARY config keyring-backend file
$BINARY config node tcp://localhost:${PORT}657
$BINARY init $NODENAME --chain-id $CHAIN

# Set peers and seeds
PEERS="5f9b3338ecce8b4d9149f4fbb10b0fe9c2a4e2a7@35.207.191.200:26656,9fe9cc32880be11134e1ec360a61082541019233@93.189.30.100:26656,0d1943a64d1aef6eae58f1766489a18f6e80a467@44.198.191.5:26656,65de9e04f72197e37ee200e078d59339edf0002d@3.38.218.148:26656,7cfb03e6f4ac2256e1ea4ee3faf2eb8ae6dfd542@46.4.107.112:11756,00f6b9a373d3ab6a407b46601d5e743884913ddc@65.108.15.85:26656,d9bd9752b4be9ee962a26400f2eda2288b54dc20@146.190.85.56:26656,d2247f7b919f0781c90ee61958d7044665a22d38@134.65.193.224:26656,4ebf87085c2a3cc65d09549938985cf72a3c7734@65.108.97.229:26656,3dd4b9df460b29232665f78e701300a42001ac11@65.108.130.171:26656,138d3af385311b0ffb1751069945f46c881275e3@146.190.173.1:32444,09441e5847b1a75894ad89870463e3d6354d22e2@135.181.220.43:26656,e792798bb79353248487700d21448e69f95f7ffe@185.248.24.19:26676,919e852269724596547466ef7faebb56cf302b13@3.80.235.110:26656,be950bebc110f4e7ca9e0d392e810968ac07e8a0@35.239.103.93:26656,d63f8991947f4225802f8e1b175b374ae1c4c382@65.108.0.165:11756,04d72a9c307a5cc5763cd105b9d41d8d0405d983@57.128.20.147:30156,84ef902da4eff54bec24d080100cefc035a3f19d@65.108.231.174:26656,983d6a7cda9d64bdc7fccbf56e48263021ed1999@138.201.16.240:12095,a0fbc6223d466ad3092aa9c0596d2379ebad3047@176.34.66.249:26656,20a61f70d93af978a3bc1d6be634a57918934f79@3.128.166.0:26656,b1c95364b661db23251f7071b6b7ee12eb3d2b42@34.124.197.220:26656,df366d15d28a4cb50b486b21f0f2666cb387c754@35.79.22.231:26656,f4afbddb64f530d11a6dd599dd6181232e477ca8@34.123.191.31:26656,8fff243159183fa696b5021e990bc056a5130c70@141.94.215.5:26656,2a13fcdb77af7248f0799cd540a8c27c218586f4@38.242.192.114:26656,a9cd12613bd20da7499a1488c8d678037fd19f45@3.39.191.196:26656,89757803f40da51678451735445ad40d5b15e059@164.152.161.49:26656,a817e150dc0d8bedf8dd0614364af91b8dce29fa@65.108.100.32:26661,ee6fe809365a3308b5f633c1876f512493c9f10e@78.46.48.105:26656,75f6fecc2470f0ea31dc1227e62d8c7f35e43deb@99.80.222.32:26656,02f5464c3516b9e3ffd386af5b9987c220f6164a@195.189.96.115:26656,9f217be3b0bada98024f2a23225fb794177e399a@148.251.11.28:26656,cf16eca9e4009c140ac33994b716a1d06849f5c8@18.202.153.243:26656,028b5c97ac5a01863d3f263df7a5814247094b18@23.19.122.193:26656,ddb0332ec52c5f4c8b61e17510b5849c31bf30b2@88.218.224.122:26656,f9cebdafa713321161d7842721f5f936cd592a20@78.31.71.15:26656,c8f6ff82b5a965b753122ae8e677218a07f1dc91@141.95.47.82:30156,e2ee4efb8ea8bc67e50b660975594a731646debc@146.59.81.18:30156,78551538917a1842cfcbea35a715568e12f98108@141.94.98.115:11095,cabe8b50d2e87d8560094e850bb29c5c4b9786ba@5.9.66.60:26656,a40e66ffab30d821cbf8c4484bfcf2fd6118f71a@139.180.185.11:26756,0b9f3e50fb4de554fbc9c9f46bb2a7370bf9f055@65.109.164.8:26656,bba10290da32f3cb41e15c3a192413666ce05cee@136.243.115.116:26656,3b2f33bd510f4b309a3a52ae15425f9defa5efc3@141.95.72.74:15095,1c3f219793ccb32dd1aee0d0f33d81dbfa817c29@85.17.5.140:26656,8a3d35ddbedc7271dea27105cc1a9f689ed68e5e@107.20.101.62:26656,1850c9bb038c1cb25fc83df25b0daf79ec88808d@195.15.246.75:26656,3a9ba0240541172172fa599a1aa5a43c639743ae@146.59.52.93:15095,9dc9e9b50c4cae52cdbec2034d879427b2a429ae@52.79.240.114:26656,55f10c594365cddd220b03306054821ff2ed132b@195.15.244.2:26656,4d61ab323b91e0b6a5d6dcf2f2eaf7bc7b06d375@5.161.49.37:26656,53c1d1afa22e46d3e38558053f1e515e32111c5a@169.155.169.56:26656,51db3b0e09016c58d6e1ea0e7916e15138b015be@65.108.98.218:11095,4e07b2c2ae02997d23a3a84a3f1c7aa743a35df4@95.217.197.100:26656,66b8b7a6e49f3816f55e0a53783c1c8d363f2458@146.59.85.223:11756,2caa63e6fa3acfb2b23ec0a4e4e1b52be46f34a9@198.244.228.16:26322,78412277c8433725180e6155fdab6f480e23ee11@5.161.49.66:26656,04228bed7c74c70772c0870d7b76e29097736abf@78.47.151.60:26656,b212d5740b2e11e54f56b072dc13b6134650cfb5@134.65.192.118:26656,9e2588bb4b8ba2929e33818f6e6c2e2bb03ce08e@65.108.121.190:2020,f00caa66560f8be6cf6231b2f113ea4fbf2e77d7@142.132.199.211:26656,012e7d1b69dadc50473bc29664b1de5b0e184dec@51.159.98.93:26656,519f5e97fa9c14bbce691c83fad55adc92427608@167.235.242.93:26656,9c4151b4542c7e555516c289bbc4471b0dcdf43e@3.65.40.95:26656,ad825ef6b29306d80b0eb8101133cedf7933eb5e@116.203.36.94:26656,ad119a6c95cc14181eb3a32ce2bad9c7a8b5d661@131.153.202.181:26656,ada82e8b8509ba8aeb84516247a9889b6bc9f99a@65.108.234.105:2000,56c9be653aeb2e1900397384fcb60974cd852735@54.147.11.25:26656,be83a207e5ecaeab76c4af4caa7c1e623c6f32ae@5.161.66.92:26656,6cceba286b498d4a1931f85e35ea0fa433373057@78.47.208.20:26656,f2701be4594970b32cd240689cb1dd51e81361f0@51.91.153.78:30468,92ea3c8436a77348aee4764076bac36e2a71be44@65.109.89.19:11756,a736bed795a7d9df33845d82b40a7c0aa1b11513@134.65.193.137:26656,e6861bfa9cd9b6be4915c1303f9d178c2e5bcb6f@51.222.40.84:26661,c124ce0b508e8b9ed1c5b6957f362225659b5343@169.155.169.15:26656,39b6dd50db7a917139510500aeeb67090eac12d4@141.95.124.226:31543,a07cec8341f149ed49f751146728cf81f83764ff@84.244.95.239:26656,4ba5dc58825150fc4ce944b40f95c17ec4c7b1ce@74.118.140.61:26656,3ff04a2f4a6de7d30396dfbe579f599d885c841a@5.161.131.164:26656,ce99a32f960e1ebbe1332eea3ef33b0bc2518a45@78.46.92.16:26656,08f3087b0f9c07617ad3baa4669b5e6f7fe8f91c@168.119.149.188:26656,a1b96e94be2faf51d8c7043cc55e112d1f250620@135.125.189.128:36656,ebd3a15dd7fb500fa73702c04e7e7f23f4017092@173.214.165.214:36656,67c373250c485e988c2a648cc8f80f99244baf3a@162.55.132.48:15614,a5cffc786ead063c3b6296e18363942e1409c85b@34.29.43.152:26656,0f1096278efafcf3f0d3bd5b6544e6b8dcc36a0e@206.189.129.195:26656,9c9e207110489f0208918b446a800169132bb38f@104.248.146.240:26656,f38e424db37945654159e6d9c2e48922c5c37252@157.230.247.69:26656"
SEEDS="71f96fe3eec96b9501043613a32a5a306a8f656b@goa-seeds.lavenderfive.com:10656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $GENESIS > $HOME/$FOLDER/config/genesis.json
curl -Ls $ADDRBOOK > $HOME/$FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/$FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%" $HOME/$FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$DENOM\"/" $HOME/$FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$FOLDER/$CHAIN/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$FOLDER/$CHAIN/config/app.toml

# Enable state sync
SNAP_RPC="https://goa-ordos-rpc.lavenderfive.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.ordos/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$BINARY.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$FOLDER"
Environment="DAEMON_NAME=$BINARY"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl start $BINARY
sudo systemctl daemon-reload
sudo systemctl enable $BINARY

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $BINARY\e[0m"
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $BINARY -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
