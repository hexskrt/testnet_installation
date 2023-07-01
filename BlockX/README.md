<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/blockx.jpg?raw=true">
</p>

# BlockX Network Testnet | Chain ID : blockx_12345-2

### Explorer:
>-  https://explorer.hexnodes.co/blockx-testnet

### Automatic Installer
You can setup your BlockX Network fullnode in few minutes by using automated script below.
```
wget -O blockx.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BlockX/blockx.sh && chmod +x blockx.sh && ./blockx.sh
```

### Snapshot
```
sudo systemctl stop blockxd
cp $HOME/.blockxd/data/priv_validator_state.json $HOME/.blockxd/priv_validator_state.json.backup
rm -rf $HOME/.blockxd/data

curl -L https://snap.hexnodes.co/blockx/blockx.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.blockxd/
mv $HOME/.blockxd/priv_validator_state.json.backup $HOME/.blockxd/data/priv_validator_state.json

sudo systemctl start blockxd && sudo journalctl -fu blockxd -o cat
```

### State Sync
```
sudo systemctl stop blockxd
cp $HOME/.blockxd/data/priv_validator_state.json $HOME/.blockxd/priv_validator_state.json.backup
blockxd tendermint unsafe-reset-all --home $HOME/.blockxd

STATE_SYNC_RPC=https://rpc-test.blockx.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.blockxd/config/config.toml

mv $HOME/.blockxd/priv_validator_state.json.backup $HOME/.blockxd/data/priv_validator_state.json

sudo systemctl start blockxd && sudo journalctl -u blockxd -f --no-hostname -o cat
```

### Live Peers
```
PEERS="e83b476c2de7befb553dfcc6cfe29820845ea477@164.92.203.212:26656,abb1c4e4025a762ebccd4019f352153b11cc97b6@136.243.136.241:29656,6e8c1abca57184b1b44b925260069e3de32c1f05@185.245.182.126:21256,9b3f1541f87cd52abb9cec0ef291bc228247f2a0@91.229.23.155:26656,a293f03b1df516ae1dd49f6a221a2657765e077e@158.220.100.50:21256,fa3cc9935503c3e8179b1eef1c1fde20e3354ca3@51.159.172.34:26656,026ba7d014d553b62196f371023890faa38c9427@38.242.230.118:45656,04fec5fff52c0900ecfe11a94b7d99dd97a1b528@51.161.12.93:14656,979876b4e2cb608cfd6cb2213b96e5668a7945d5@23.111.174.202:22606,bf01d33210dc0a56ad9e065e596366faa75b1288@137.184.119.60:14356,a8abd6385e7513c598c7ca7d2f4197c7b325d90a@137.184.119.85:14356,b2f7c2fc1e5fddd3fd623646868f8845520cb50c@143.198.234.168:14356,3780a79508db3c47fe2c35a8079ce552c577df6f@143.198.110.221:26656,63baa1ccf010fa620e4f38da297668c462374b8f@170.64.137.196:26656,3ecc98a3af5d672fc2ca188e8462604ae5d39062@65.21.225.10:49956,dccf886659c4afcb0cd4895ccd9f2804c7e7e1cd@143.198.101.61:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@95.214.52.139:27076,818d30649e765a16593e4996168a7107b1cb046c@143.198.97.0:26656,8caacc28a853a5bf4f6d76d49be43327addf1880@185.197.250.215:26656,2e924d516e5b92379584c57a5fc4d1907e1296ac@146.190.174.143:26656,d00711319c7ea918e0bc5922be812f8b58e7f775@65.108.208.155:26656,d46d9aa3debca8d05af1987cb91a71cdd32aad25@147.182.240.58:21256,047bcbad715412ea646c40c690955447a3965c56@51.79.78.121:26656,cdf456fbe774e55aa794eeaa5280a78f1cf0738b@65.108.66.34:26656,78dd8371dae4f081e76a32f9b5e90037737a341a@162.19.239.112:26656,c90bd84a46f2cca8c06dd11031474611dbca41c1@139.59.233.146:21256,6b01445d44bbf9de7b895cc1a5245df33e6cebea@37.252.184.231:26656,f91f969959e35cc37e79bfa18b4f33ad701c76d8@149.102.144.142:22656,db3bc1c189bb50174a0d5a799b5ec5f5c41ad7a2@5.161.120.77:26656,14cad9ecd2b421c9035e52e5d779fbe84bddd134@65.109.82.112:2936,1ee1c4f88faeaaae11b9640a2cb6401c11b210d7@141.94.193.12:26656,c5b7f96ac776034107a7f7a546a2c065de081c09@89.58.19.91:26656,49a5a62543f5fec60db42b00d9ebe192c3185e15@143.198.97.96:26656,0b406405e7d73d312efec1e086b60e61e99e5f3f@165.232.77.196:26656,7188d4ccac22c8117aed2970433f050778ff3a25@146.190.142.13:26656,a1bb8338a8bbe5f76a8708856f8fb4c301f1c168@207.180.249.127:26656,d1771238066b86ede263dacb0e4e54cdf11df19b@131.153.142.181:26656,544b02ceacb0edcc043c7534db8516c20e25f12e@38.146.3.205:21456,2786d942f440d22d8c286b35eb359f7c026585cb@38.242.207.201:26656,e5de520d1e4ff340d5f378e67ee97b7e3bbfdce8@165.22.59.131:21256,28f3847bbda32e8daf84bc2755a0761cb1118491@31.220.80.94:26656,9406c6184876b0678e7c5a705899437791a80ed7@136.243.88.91:7130,3fcb893cfc75546f3ffae9f8e81a230072639249@65.108.206.74:19656,357cc44dacfd13ed967bfe5b057cb82effd26db7@178.128.59.246:26656,b4302cc876f69b3726d55506e2fcfa49f18757e9@137.184.45.113:26656,794ffecc8955191dc3be86329df52c5a0424ab98@167.172.65.254:21256"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.blockxd/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BlockX/addrbook.json > $HOME/.blockxd/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BlockX/genesis.json > $HOME/.blockxd/config/genesis.json
```